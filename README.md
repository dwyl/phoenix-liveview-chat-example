# LiveviewChat

[![Elixir CI](https://github.com/dwyl/phoenix-liveview-chat-example/actions/workflows/cy.yml/badge.svg)](https://github.com/dwyl/phoenix-liveview-chat-example/actions/workflows/cy.yml)


<div align="center">
**Try it at: [liveview-chat-example.herokuapp](https://liveview-chat-example.herokuapp.com/)**
</div>

## Content
- [Initialisation](#initialisation)
- [LiveView Route, Controller and Template](#liveview-route-controller-and-template)
- [Migration and Schema](#migration-and-schema)
- [Handle events](#handle-events)
- [PubSub](#pubsub)
 
## Initialisation

Let's start by creating the new `liveview_chat` Phoenix application.

```sh
mix phx.new liveview_chat --no-mailer --no-dashboard
```

We don't need mail or dashboard features. You can learn more about creating
a new Phoenix application with `mix help phx.new`

Run `mix deps.get` to retrieve the dependencies, then make sure you have
the `liveview_chat_dev` Postgres database available.
You should now be able to start the application with `mix phx.server`:

![phx.server](https://user-images.githubusercontent.com/6057298/142623156-ab767540-2561-43e3-bc87-1c4f89778d21.png)

## LiveView Route, Controller and Template

Open `lib/liveview_chat_web/router.ex` file to remove the current default `PageController`
controller and add instead a `MessageLive` controller:


```elixir
scope "/", LiveviewChatWeb do
  pipe_through :browser

  live "/", MessageLive
end
```

and create the `live` folder and the  controller at `lib/liveview_chat_web/live/message_live.ex`:

```elixir
defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("messages.html", assigns)
  end
end
```

A liveView controller requires the function `mount` and `render` to be defined.
To keep the controller simple we are just returning the {:ok, socket} tuple
without any changes and the render view calls the `message.html.heex` template.
So let's create now the `MessageView` module and the `message` template:

Similar to normal Phoenix view create the `lib/liveview_chat_web/views/message_view.ex`
file:

```elixir
defmodule LiveviewChatWeb.MessageView do
  use LiveviewChatWeb, :view
end
```

Then the template at `lib/liveview_chat_web/templates/message/message.html.heex`:

```heex
<h1>LiveView Message Page</h1>
```

Finally to make the root layout simpler. Update the `body` content
of the `lib/liveview_chat_web/templates/layout/root.html.heex` to: 

```
<body>
    <header>
      <section class="container">
        <h1>LiveView Chat Example</h1>
      </section>
    </header>
    <%= @inner_content %>
</body>
```


Now if you refresh the page you should see the following:

![live view page](https://user-images.githubusercontent.com/6057298/142659332-bc15ed66-195a-482f-8925-ec6c57c478c0.png)

At this point we want to update the tests!
Create the `test/liveview_chat_web/live` folder and the `message_live_test.exs`:

```elixir
defmodule LiveviewChatWeb.MessageLiveTest do
  use LiveviewChatWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<h1>LiveView Message Page</h1>"

    {:ok, _view, _html} = live(conn)
  end
end

```

We are testing that the `/` endpoint is accessible when the socket is not yet connected,
then when it is with the `live` function.

See also the [LiveViewTest module](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
for more information about testing and liveView.

Finally you can delete all the default generated code linked to the `PageController`.
- `rm test/liveview_chat_web/controllers/page_controller_test.exs`
- `rm lib/liveview_chat_web/controllers/page_controller.ex`
- `rm test/liveview_chat_web/views/page_view_test.exs`
- `rm lib/liveview_chat_web/views/page_view.ex`
- `rm -r lib/liveview_chat_web/templates/page`

You can now run the test with `mix test` command:

![image](https://user-images.githubusercontent.com/6057298/142856124-5c2d9cc6-9208-4567-b781-0b46081cfed1.png)


## Migration and Schema

Now that we have the liveView structure defined,
we can start to focus on creating messages.
The database will save the message and the name of the user.
So we can create a new schema and migration:

```sh
mix phx.gen.schema Message messages name:string message:string
```

and don't forget to run `mix ecto.migrate` to create the new `messages` table.

We can now update the `Message` schema to add functions for creating
new messages and listing the existing messages. We'll also update the changeset
to add requirements and validations on the message text.
Open the `lib/liveview_chat/message.ex` file and update the code with the following:

```elixir
defmodule LiveviewChat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LiveviewChat.Repo
  alias __MODULE__

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
    |> validate_length(:message, min: 2)
  end

  def create_message(attrs) do
    %Message{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def list_messages do
    Message
    |> limit(20)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
```

We have added the `validate_length` function on the message input to make
sure messages have at least 2 characters. This is just an example to show how
the changeset works with the form on the liveView page.

We then created the `create_message` and `list_messages` functions.
Similar to [phoenix-chat-example](https://github.com/dwyl/phoenix-chat-example/)
we limit the number of messages returned to the latest 20.


We can now update the `lib/liveview_chat_web/live/message_live.ex` file to use
the `list_messages` function:

```elixir
def mount(_params, _session, socket) do
  messages = Message.list_messages() |> Enum.reverse()
  changeset = Message.changeset(%Message{}, %{})
  {:ok, assign(socket, messages: messages, changeset: changeset)}
end
```

We get the list of messages and we create a changeset that we'll use for the
message form.
We then [assign](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#assign/2)
the changeset and the messages to the socket which will display them on the liveView page.

If we now update the `message.htlm.heex` file to:

```html
<ul id='msg-list'>
   <%= for message <- @messages do %>
     <li id={message.id}>
       <b><%= message.name %>:</b>
       <%= message.message %>
     </li>
   <% end %>
</ul>

<.form let={f} for={@changeset}, id="form", phx-submit="new_message">
   <%= text_input f, :name, id: "name", placeholder: "Your name", autofocus: "true"  %>
   <%= error_tag f, :name %>

   <%= text_input f, :message, id: "msg", placeholder: "Your message"  %>
   <%= error_tag f, :message %>

   <%= submit "Send"%>
</.form>
```




We should see the following page:

![image](https://user-images.githubusercontent.com/6057298/142882923-db490aea-5af6-49d4-9e45-38c75d05e234.png)


the `<.form></.form>` syntax is how to use the form [function component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#content).
> A function component is any function that receives an assigns map as argument and returns a rendered struct built with the ~H sigil.





Finally let's make sure the test are still passing by updating the `assert` to:

```elixir
assert html_response(conn, 200) =~ "<h1>LiveView Chat Example</h1>"
```

As we have deleted the `LiveView Message Page` h1 title, we can test instead
the title in the root layout and make sure the page is still displayed correctly.

## Handle events

At the moment if we submit the form nothing will happen.
If we look at the server log, we see the following:

```sh
** (UndefinedFunctionError) function LiveviewChatWeb.MessageLive.handle_event/3 is undefined or private
    (liveview_chat 0.1.0) LiveviewChatWeb.MessageLive.handle_event("new_message", %{"_csrf_token" => "fyVPIls_XRBuGwlkMhxsFAciRRkpAVUOLW5k4UoR7JF1uZ5z2Dundigv", "message" => %{"message" => "", "name" => ""}}, #Phoenix.LiveView.Socket
```

On submit the form is creating a new event defined with `phx-submit`:

```elixir
<.form let={f} for={@changeset}, id="form", phx-submit="new_message">
```

However this event is not managed on the server yet, we can fix this by adding the
`handle_event` function in `lib/liveview_chat_web/live/message_live.ex`:

```elixir
def handle_event("new_message", %{"message" => params}, socket) do
  case Message.create_message(params) do
    {:error, changeset} ->
      {:noreply, assign(socket, changeset: changeset)}

    {:ok, _message} ->
      changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
      {:noreply, assign(socket, changeset: changeset)}
    end
end
```

The `create_message` function is called with the values from the form.
If an error occurs while trying to save the information in the database,
for example the changeset can return an error if the name or the message is
empty or if the message is too short, the changeset is assigned again to the socket.
This will allow the form to display the error information:

![image](https://user-images.githubusercontent.com/6057298/142921586-2ed0e7b4-c2a1-4cd2-ab87-154ff4e9f4d8.png)

If the message is saved without any errors,
we are creating a new changeset which contains the name from the form
to avoid people to enter their name again in the form, and we assign the new
changeset to the socket.


![image](https://user-images.githubusercontent.com/6057298/142921871-2feb20c2-906e-4640-8781-f8ea776dc05b.png)

Now the form is displayed we can add the following tests:


```elixir
  test "name can't be blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "", message: "hello"})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: ""})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "minimum message length", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: "h"})
           |> render_submit() =~ "should be at least 2 character(s)"
  end
```

We are using the [form](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#form/3) function to select the form and trigger
the submit event with different values for the name and the message.
We are testing that errors are properly displayed.


## PubSub

Instead of having to reload the page to see the newly created messages,
we can use [PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) 
to inform all connected clients that a new message has been created and to
update the UI to display the new message.

We're going to update the `lib/liveview_chat/message.ex` file to add two functions.

- `subscribe` will be called when a client has properly displayed the liveView page
and listen for new messages.

- `notify` will be call each time a new message is created and to broadcast the
new message to the other connected clients.


Let's first add the line `alias Phoenix.PubSub` at the top of the `message.ex` file.
Then we can create the `subscribe` function which is just a wrapper function
for [Phoenix.PubSub.subscribe](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html#subscribe/3):

```elixir
def subscribe() do
  PubSub.subscribe(LiveviewChat.PubSub, "liveview_chat")
end
```

We can now connect the client when the LiveView page is rendered.
For that we update the `mount` function with:

```elixir
  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})
    {:ok, assign(socket, messages: messages, changeset: changeset)}
  end
```

We check the socket is connected then call the new subscribe function

Now that we have a connected client we can create the `notify` function.
First we update the `create_message` function to call `notify`:

```elixir
  def create_message(attrs) do
    %Message{}
    |> changeset(attrs)
    |> Repo.insert()
    |> notify(:message_created)
  end
```

`Repo.insert` can either returns `{:ok, message}` or `{:error, reason}`,
so we need to define `notify` to be able to manage these two cases:

```elixir
  def notify({:ok, message}, event) do
    PubSub.broadcast(LiveviewChat.PubSub, "liveview_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}
```

We need to update `handle_event` function as the return value of `create_message`
is now different:

```elixir
def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      :ok -> # broadcast returns :ok if there are no errors
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
    end
end
```

Again the `notify` function is just a wrapper around the `PubSub.broadcast` function.

The last step is to handle the `:message_created` event by defining the `handle_info` function
in `lib/liveview_chat_web/live/message_live.ex`:

```elixir
def handle_info({:message_created, message}, socket) do
  messages = socket.assigns.messages ++ [message]
  {:noreply, assign(socket, messages: messages)}
end
```

When the event is received, the new message is added to the list of messages.
The new list is then assigned to the socket which will update the UI and display
the new message.

Add the following tests to make sure that messages are correctly displayed on the page:

```elixir
  test "message form submitted correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: "hi"})
           |> render_submit()

    assert render(view) =~ "<b>Simon:</b>"
    assert render(view) =~ "hi"
  end

  test "handle_info/2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view)
    # send :created_message event when the message is created
    Message.create_message(%{"name" => "Simon", "message" => "hello"})
    # test that the name and the message is displayed
    assert render(view) =~ "<b>Simon:</b>"
    assert render(view) =~ "hello"
  end
```

You should now have a functional chat application using liveView!


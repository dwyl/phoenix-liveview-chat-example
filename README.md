<div align="center">

# `LiveView` Chat _Tutorial_ 

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/phoenix-liveview-chat-example/ci.yml?label=build&style=flat-square&branch=main)
[![codecov test coverage](https://img.shields.io/codecov/c/github/dwyl/phoenix-liveview-chat-example/main.svg?style=flat-square)](https://codecov.io/github/dwyl/phoenix-liveview-chat-example?branch=main)
[![HitCount](https://hits.dwyl.com/dwyl/phoenix-liveview-chat-example.svg?style=flat-square&show=unique)](https://hits.dwyl.com/dwyl/phoenix-liveview-chat-example)

**Try it**: [**liveview-chat-example.herokuapp**](https://liveview-chat-example.herokuapp.com)

![liveview-chat-with-tailwind-css](https://user-images.githubusercontent.com/194400/174119023-bb83f5f4-867c-4bfa-a005-26b39c700137.gif)

</div>

# Why? 🤷

We _really_ wanted a **_Free_ & Open Source** 
real-world example
with _full_ code,
tests and auth. <br />
We wrote this 
so we could point 
people in our team/community 
learning **`Phoenix LiveView`** to it. <br />
This `LiveView` example/tutorial takes you from zero 
to **_fully_ functioning app**
in **20 minutes**. 

# What? 💬

Here is the table of contents 
of what you can expect to cover 
in this example/tutorial:
- [`LiveView` Chat _Tutorial_](#liveview-chat-tutorial)
- [Why? 🤷](#why-)
- [What? 💬](#what-)
- [Who? 👤](#who-)
- [_How_? 💻](#how-)
  - [0. Prerequisites](#0-prerequisites)
  - [1. Create `Phoenix` App](#1-create-phoenix-app)
  - [2. Create `live` Directory, `LiveView` Controller and Template](#2-create-live-directory-liveview-controller-and-template)
  - [3. Update `router.ex`](#3-update-routerex)
  - [4. Update Tests](#4-update-tests)
  - [5. Migration and Schema](#5-migration-and-schema)
  - [6 Update `mount/3` function](#6-update-mount3-function)
  - [7. Update Template](#7-update-template)
    - [7.1 Update the Test Assertion](#71-update-the-test-assertion)
  - [8. Handle Message Creation Events](#8-handle-message-creation-events)
    - [8.1 Test Message Creation Validation](#81-test-message-creation-validation)
  - [9. PubSub](#9-pubsub)
    - [9.1 Notify Connected Clients of New Messages](#91-notify-connected-clients-of-new-messages)
    - [9.2 Update `mount/3`](#92-update-mount3)
    - [9.3 Update `handle_event/3`](#93-update-handle_event3)
    - [9.4 Create `handle_info/2`](#94-create-handle_info2)
    - [9.5 Test Messages are Displaying](#95-test-messages-are-displaying)
  - [10. Hooks](#10-hooks)
  - [11. Optional: Temporary assigns](#11-optional-temporary-assigns)
  - [12. Authentication](#12-authentication)
    - [12.1 Create `AUTH_API_KEY`](#121-create-auth_api_key)
    - [12.2 Install `auth_plug` ⬇️](#122-install-auth_plug-️)
    - [12.3 Create the _Optional_ Auth Pipeline in `router.ex`](#123-create-the-optional-auth-pipeline-in-routerex)
    - [12.4 Create `AuthController`](#124-create-authcontroller)
    - [12.5 Create `on_mount/4` functions](#125-create-on_mount4-functions)
  - [14. Presence](#14-presence)
  - [15. Tailwind CSS Stylin'](#15-tailwind-css-stylin)
- [What's _Next_?](#whats-next)

# Who? 👤

Anyone learning `Phoenix LiveView` 
wanting a self-contained tutorial
including: 
`Setup`, `Testing`, `Authentication`, `Presence`,

# _How_? 💻




## 0. Prerequisites

It's _recommended_, 
though _not required_, 
that you follow the 
[**`LiveView` Counter Tutorial**](https://github.com/dwyl/phoenix-liveview-counter-tutorial)
as this one is more advanced.
At least, checkout the list of 
[prerequisites](https://github.com/dwyl/phoenix-liveview-counter-tutorial#prerequisites-what-you-need-before-you-start-)
so you know what you need to have
installed on your computer before 
you start this adventure!

Provided you have 
**`Elixir`**, **`Phoenix`** 
and **`Postgres`** installed,
you're good to go!

<br />

## 1. Create `Phoenix` App

Start by creating the new **`liveview_chat`** `Phoenix` application:

```sh
mix phx.new liveview_chat --no-mailer --no-dashboard
```

We don't need `email` or `dashboard` features 
so we're excluding them from our app.
You can learn more about creating
new Phoenix apps by running:
`mix help phx.new`

Run `mix deps.get` to retrieve the dependencies.
then create the
**`liveview_chat_dev` Postgres database**
by running the command:

```sh
mix ecto.setup
```

You should see output similar to the following:

```sh
The database for LiveviewChat.Repo has been created

14:20:19.71 [info]  Migrations already up
```

Once that command succeeds 
You should now be able to start the application
by running the command:

```sh
mix phx.server
```

You will see terminal output similar to the following:

```sh
[info] Running LiveviewChatWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[debug] Downloading esbuild from https://registry.npmjs.org/esbuild-darwin-64/-/esbuild-darwin-64-0.14.29.tgz
[info] Access LiveviewChatWeb.Endpoint at http://localhost:4000
[watch] build finished, watching for changes...
```

When you open the URL:
[`http://localhost:4000`](http://localhost:4000)
in your web browser you should see something similar to:

![phx.server](https://user-images.githubusercontent.com/6057298/142623156-ab767540-2561-43e3-bc87-1c4f89778d21.png)

<br />

## 2. Create `live` Directory, `LiveView` Controller and Template

Create the `lib/liveview_chat_web/live` folder 
and the controller at 
`lib/liveview_chat_web/live/message_live.ex`:

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
> **Note**: neither the file name nor the code 
> has the word "**controller**" anywhere. 
> Hopefully it's not confusing.
> It's a "controller" in the sense 
> that it controls what happens in the app. 

A **`LiveView` controller** requires 
the functions **`mount/3`** and **`render/1`** to be defined. <br />
To keep the controller simple the **`mount/3`**
is just returning the `{:ok, socket}` tuple
without any changes.
The **`render/1`** 
invokes 
`LiveviewChatWeb.MessageView.render/2` (included with `Phoenix`)
which renders the **`messages.html.heex`** `template`
which we will define below.

Create the 
`lib/liveview_chat_web/views/message_view.ex`
file:

```elixir
defmodule LiveviewChatWeb.MessageView do
  use LiveviewChatWeb, :view
end
```

This is similar to regular `Phoenix` `view`;
nothing special/interesting here.

Next, create the 
**`lib/liveview_chat_web/templates/message`** 
directory,
then create  
**`lib/liveview_chat_web/templates/message/messages.html.heex`**
file 
and add the following line of `HTML`:

```html
<h1>LiveView Message Page</h1>
```

Finally, to make the **root layout** simpler, 
open the 
`lib/liveview_chat_web/templates/layout/root.html.heex`
file and 
update the contents of the `<body>` to:

```html
<body>
  <header>
    <section class="container">
      <h1>LiveView Chat Example</h1>
    </section>
  </header>
  <%= @inner_content %>
</body>
```

## 3. Update `router.ex`

Now that you've created the necessary files,
open the router
`lib/liveview_chat_web/router.ex` 
replace the default route `PageController` controller:

```elixir
get "/", PageController, :index
```

with `MessageLive` controller:


```elixir
scope "/", LiveviewChatWeb do
  pipe_through :browser

  live "/", MessageLive
end
```

Now if you refresh the page you should see the following:

![live view page](https://user-images.githubusercontent.com/194400/172560880-86e92751-2c00-4daf-9e6a-b428dec344ea.png)

## 4. Update Tests

At this point we have made a few changes 
that mean our automated test suite will no longer pass ... 
Run the tests in your command line with the following command:
```sh
mix test
```

You will see output similar to the following:

```sh
Generated liveview_chat app
..

  1) test GET / (LiveviewChatWeb.PageControllerTest)
     test/liveview_chat_web/controllers/page_controller_test.exs:4
     Assertion with =~ failed
     code:  assert html_response(conn, 200) =~ "Welcome to Phoenix!"
     left:  "<!DOCTYPE html><html lang=\"en\"> <head> <meta charset=\"utf-8\"> <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
     <title data-suffix=\" · Phoenix Framework\">LiveviewChat · Phoenix Framework</title> <link phx-track-static rel=\"stylesheet\" href=\"/assets/app.css\">    <script defer phx-track-static type=\"text/javascript\" src=\"/assets/app.js\"></script>  </head>  
     <body> <header> <section class=\"container\"> 
     <h1>LiveView Chat Example</h1></section> </header>
     <h1>LiveView Message Page</h1></main></div>  </body></html>"
     right: "Welcome to Phoenix!"
     stacktrace:
       test/liveview_chat_web/controllers/page_controller_test.exs:6: (test)

Finished in 0.03 seconds (0.02s async, 0.01s sync)
3 tests, 1 failure
```

This is because the `page_controller_test.exs` 
is still expecting the homepage to contain the 
**`"Welcome to Phoenix!"`** text.

Let's update the tests!
Create the 
**`test/liveview_chat_web/live`** 
folder and the 
**`message_live_test.exs`** 
file within it:
**`test/liveview_chat_web/live/message_live_test.exs`**

Add the following test code to it:

```elixir
defmodule LiveviewChatWeb.MessageLiveTest do
  use LiveviewChatWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView Message Page"

    {:ok, _view, _html} = live(conn)
  end
end
```

We are testing that the `/` endpoint 
is accessible and has the text
**`"LiveView Message Page"`** on the page.

See also the
[LiveViewTest module](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
for more information about testing and liveView.

Finally you can delete all the default generated code linked to the `PageController`:

- `rm test/liveview_chat_web/controllers/page_controller_test.exs`
- `rm lib/liveview_chat_web/controllers/page_controller.ex`
- `rm test/liveview_chat_web/views/page_view_test.exs`
- `rm lib/liveview_chat_web/views/page_view.ex`
- `rm -r lib/liveview_chat_web/templates/page`

You can now run the test again with `mix test` command.
You should see the following (tests passing):

```sh
Generated liveview_chat app
...

Finished in 0.1 seconds (0.06s async, 0.1s sync)
3 tests, 0 failures

Randomized with seed 841084
```
## 5. Migration and Schema

With the `LiveView` structure defined,
we can focus on creating messages.
The database will save the message 
and the name of the sender.
Let's create a new schema and migration:

```sh
mix phx.gen.schema Message messages name:string message:string
```

> **Note**: don't forget to run `mix ecto.migrate` 
> to create the new `messages` table in the database.

We can now update the `Message` schema 
to add functions for creating new messages 
and listing the existing messages. 
We'll also update the changeset
to add requirements 
and validations on the message text.
Open the `lib/liveview_chat/message.ex` file 
and update the code with the following:

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

We have added the `validate_length` function 
on the message input to ensure
that messages have at **_least_ 2 characters**. 
This is just an example to show how
the `changeset` validation works 
with the form on the `LiveView` page.

We then created the `create_message/1` 
and `list_messages/0` functions.
Similar to 
[phoenix-chat-example](https://github.com/dwyl/phoenix-chat-example/)
we `limit` the number of messages returned 
to the **_latest_ 20**.

## 6 Update `mount/3` function

Open the 
`lib/liveview_chat_web/live/message_live.ex` 
file 
and add the following line at line 3:

```elixir
alias LiveviewChat.Message
```

Next update the `mount/3` function in the
`lib/liveview_chat_web/live/message_live.ex` 
file to use
the `list_messages` function:

```elixir
def mount(_params, _session, socket) do
  messages = Message.list_messages() |> Enum.reverse()
  changeset = Message.changeset(%Message{}, %{})
  {:ok, assign(socket, changeset: changeset, messages: messages)}
end
```

`mount/3` will now get the list of `messages` 
and create a `changeset` 
that will be used for the message form.
We then 
[assign](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#assign/2)
the `changeset` and the `messages` to the socket which will display them on the liveView page.

## 7. Update Template

Update the 
`messages.html.heex` 
template to the following code:

```html
<ul id='msg-list' phx-update="append">
  <%= for message <- @messages do %>
    <li id={"msg-#{message.id}"}>
      <b><%= message.name %>:</b>
      <%= message.message %>
    </li>
  <% end %>
</ul>

<.form let={f} for={@changeset} id="form" phx-submit="new_message" phx-hook="Form">
  <%= text_input f, :name, id: "name", placeholder: "Your name", autofocus: "true"  %>
  <%= error_tag f, :name %>

  <%= text_input f, :message, id: "msg", placeholder: "Your message"  %>
  <%= error_tag f, :message %>

  <%= submit "Send"%>
</.form>
```

It first displays the new messages
and then provides a form for people 
to `create` a new message.

If you refresh the page, 
you should see the following:

![image](https://user-images.githubusercontent.com/6057298/142882923-db490aea-5af6-49d4-9e45-38c75d05e234.png)


The `<.form></.form>` syntax is how to use the form
[function component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#content).
> A function component is any function
that receives an `assigns` map as argument
and returns a rendered `struct` built with the `~H` sigil.

### 7.1 Update the Test Assertion

Finally let's make sure the test are still passing by updating the `assert` 
in the `test/liveview_chat_web/live/message_live_test.exs` file
to:

```elixir
assert html_response(conn, 200) =~ "LiveView Chat"
```

As we have deleted the `LiveView Message Page` h1 title, 
we can instead test for the title in the root layout 
and make sure the page is still displayed correctly.

## 8. Handle Message Creation Events

At the moment if we run the `Phoenix` app `mix phx.server`
and submit the form in the browser nothing will happen.
If we look at the server log, we see the following:

```
** (UndefinedFunctionError) function LiveviewChatWeb.MessageLive.handle_event/3
  is undefined or private
  (liveview_chat 0.1.0) LiveviewChatWeb.MessageLive.handle_event("new_message",
  %{"_csrf_token" => "fyVPIls_XRBuGwlkMhxsFAciRRkpAVUOLW5k4UoR7JF1uZ5z2Dundigv",
  "message" => %{"message" => "", "name" => ""}}, #Phoenix.LiveView.Socket
```

On submit the form is creating a new event defined with `phx-submit`:

```elixir
<.form let={f} for={@changeset} id="form" phx-submit="new_message">
```

However this event is not managed on the server yet,
we can fix this by adding the
`handle_event/3` function in
`lib/liveview_chat_web/live/message_live.ex`:

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
If an `error` occurs while trying to save the information in the database,
for example the `changeset` can return an error if the name or the `message` is
empty or if the `message` is too short, the `changeset` is assigned again to the socket.
This will allow the form to display the `error` information:

![name-cant-be-blank](https://user-images.githubusercontent.com/6057298/142921586-2ed0e7b4-c2a1-4cd2-ab87-154ff4e9f4d8.png)

If the message is saved without any errors,
we are creating a new changeset which contains the name from the form
to avoid people having to enter their name again in the form, 
and we assign the new changeset to the socket.


![chat-basic-message](https://user-images.githubusercontent.com/6057298/142921871-2feb20c2-906e-4640-8781-f8ea776dc05b.png)

### 8.1 Test Message Creation Validation

Now the form is displayed we can add the following tests
to `test/liveview_chat_web/live/message_live_test.exs`:

```elixir
  import Plug.HTML, only: [html_escape: 1]

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

We are using the
[`form/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#form/3)
function to select the form and trigger
the submit event with different values for the name and the message.
We are testing that errors are properly displayed.

## 9. PubSub

Instead of having to reload the page to see the newly created messages,
we can use [PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) 
(**Pub**lish **Sub**scribe)
to inform all connected clients 
that a new message has been created and to
update the UI to display the new message.

Open the `lib/liveview_chat/message.ex` file 
and add the following line near the top: 
```elixir
alias Phoenix.PubSub
```

Next add the following 3 functions:

```elixir
  def subscribe() do
    PubSub.subscribe(LiveviewChat.PubSub, "liveview_chat")
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(LiveviewChat.PubSub, "liveview_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}
```

`subscribe/0` will be called when a client has properly displayed the liveView page
and listen for new messages. 
It is just a wrapper function for 
[Phoenix.PubSub.subscribe](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html#subscribe/3).

`notify/2` is invoked each time a new message is created 
to broadcast the message to the connected clients.
`Repo.insert` can either returns `{:ok, message}` or `{:error, reason}`,
so we need to define `notify/2` handle both cases.

### 9.1 Notify Connected Clients of New Messages

Update the `create_message/1` function in `message.ex`
to invoke our newly created `notify/2` function:

```elixir
  def create_message(attrs) do
    %Message{}
    |> changeset(attrs)
    |> Repo.insert()
    |> notify(:message_created)
  end
```

### 9.2 Update `mount/3` 

We can now connect the client 
when the `LiveView` page is rendered.
At the top of the 
`lib/liveview_chat_web/live/message_live.ex`
file,
add the following line:

```elixir
alias LiveviewChat.PubSub
```


Then update the `mount/3` function with:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Message.subscribe()

  messages = Message.list_messages() |> Enum.reverse()
  changeset = Message.changeset(%Message{}, %{})
  {:ok, assign(socket, messages: messages, changeset: changeset)}
end
```

`mount/3` now checks the socket is connected 
then calls the new `Message.subscribe/0` function.


### 9.3 Update `handle_event/3`

Since the return value of `create_message/1` has changed,
we need to update `handle_event/3` to the following:

```elixir
def handle_event("new_message", %{"message" => params}, socket) do
  case Message.create_message(params) do
    {:error, changeset} ->
      {:noreply, assign(socket, changeset: changeset)}

    :ok -> # broadcast returns :ok (just the atom!) if there are no errors
      changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
      {:noreply, assign(socket, changeset: changeset)}
  end
end
```
### 9.4 Create `handle_info/2` 

The last step 
is to handle the `:message_created` event 
by defining the `handle_info/2` function
in `lib/liveview_chat_web/live/message_live.ex`:

```elixir
def handle_info({:message_created, message}, socket) do
  messages = socket.assigns.messages ++ [message]
  {:noreply, assign(socket, messages: messages)}
end
```

When the event is received, 
the new message is added to the list of existing messages.
The new list is then assigned to the socket 
which will update the UI 
to display the new message.

### 9.5 Test Messages are Displaying

Add the following tests to 
`test/liveview_chat_web/live/message_live_test.exs`
to ensure that messages are correctly displayed on the page:

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
Run the `Phoenix` App with:

```sh
mix phx.server
```

Visit the App [`localhost:4000`](http://localhost:4000/)
in 2 or more browsers,
and send yourself some messages!

![liveview-chat-demo](https://user-images.githubusercontent.com/194400/174016930-52b73247-eb7e-4c3e-8a4d-db0929aacc39.gif)


## 10. Hooks

One issue we can notice is that the message input doesn't always
reset to an empty value after sending a message using the `Enter` key
on the input field. This forces us to remove the
previous message manually before writing and sending a new one.

The reason is:

> The JavaScript client is always the source of truth for current input values.
For any given **input with focus**, `LiveView` will never overwrite
the input's current value, 
even if it deviates from the server's rendered updates.
see: https://hexdocs.pm/phoenix_live_view/form-bindings.html#javascript-client-specifics


Our solution is to use `phx-hook` to run some javascript on the client
after one of the `LiveView` life-cycle callbacks 
(mounted, beforeUpdated, updated,
destroyed, disconnected, reconnected).

Let's add a hook to monitor when the message form is `updated`.
In the `message.html.heex` file 
add the `phx-hook` attribute to the `<.form>` element:

```html
<.form let={f} for={@changeset} id="form" phx-submit="new_message" phx-hook="Form">
```

Then in the `assets/js/app.js` file,
add the following `JavaScript` logic:


```js
// get message input element
let msg = document.getElementById('msg');                                           

// define "Form" hook, the name must match the one
// defined with phx-hoo="Form"
let Hooks = {}
Hooks.Form = {
  // Each time the form is updated run the code in the callback
  updated() {
    // If no error displayed reset the message value
    if(document.getElementsByClassName('invalid-feedback').length == 0) {
      msg.value = '';
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks}) // Add hooks: Hooks
```

The main logic to reset the message value is contained inside the `updated()`
callback function:

```js
if(document.getElementsByClassName('invalid-feedback').length == 0) {
  msg.value = '';
}
```

Before setting the value to an empty string, 
we check first that no errors are displayed 
on the form by checking for the `invalid-feedback` CSS class.
(read more about feedback:
  https://hexdocs.pm/phoenix_live_view/form-bindings.html#phx-feedback-for )

The final step is to set the `hooks` on the `liveSocket` 
with `hooks: Hooks`.
The message input should now be reset when a new message is added!


## 11. Optional: Temporary assigns

At the moment the `mount/3` function first initializes the list of messages
by loading the latest 20 messages from the database:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Message.subscribe()

  messages = Message.list_messages() |> Enum.reverse() # get the list of messages
  changeset = Message.changeset(%Message{}, %{})

  {:ok, assign(socket, messages: messages, changeset: changeset)} ## assigns messages to socket
end
```

Then each time a new message is created the `handle_info` function append
the message to the list of messages:

```elixir
def handle_info({:message_created, message}, socket) do
  messages = socket.assigns.messages ++ [message] # append new message to the existing list
  {:noreply, assign(socket, messages: messages)}
end
```

This can cause issues if the list of messages becomes too long as
all the messages are kept in memory on the server.

To minimize the use of the memory, 
we can define messages as a temporary `assign`:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Message.subscribe()

  messages = Message.list_messages() |> Enum.reverse()
  changeset = Message.changeset(%Message{}, %{})

  {:ok, assign(socket, messages: messages, changeset: changeset),
  temporary_assigns: [messages: []]}
end
```

The list of messages is retrieved once, then it is reset to an empty list.

Now the `handle_info/2` only needs to assign the new message to the socket:


```elixir
def handle_info({:message_created, message}, socket) do
  {:noreply, assign(socket, messages: [message])}
end
```

Finally the `heex` messages template listens for any changes in the list of messages
with `phx-update` and appends the new message to the existing displayed list.

```html
<ul id='msg-list' phx-update="append">
   <%= for message <- @messages do %>
     <li id={message.id}>
       <b><%= message.name %>:</b>
       <%= message.message %>
     </li>
   <% end %>
</ul>
```

See also the Phoenix `temporary-assigns` documentation page:
https://hexdocs.pm/phoenix_live_view/dom-patching.html#temporary-assigns

<br />

## 12. Authentication

Currently the `name` field 
is left to the person to define _manually_
before they send a message.
This is fine in a basic demo app,
but we know we can do better.
In this section we'll add authentication 
using
[**`auth_plug`**](https://github.com/dwyl/auth_plug).
That will allow people using the App 
to authenticate with their `GitHub` or `Google` account
and then pre-fill the `name` in the message form.

### 12.1 Create `AUTH_API_KEY` 

As per the 
[instructions](https://github.com/dwyl/auth_plug#2-get-your-auth_api_key-) 
first create a new **API Key** at 
https://dwylauth.herokuapp.com 
e.g:

![image](https://user-images.githubusercontent.com/194400/174044750-73dcb29a-b236-40d4-9a91-27144b675320.png)

Then create an `.env` file
and add your new created api key:

```.env
export AUTH_API_KEY=88SwQGzaZoJYXs6ihvwMy2dRVtm6KVeg4tSCjRKtwDvMUYUbi/88SwQDatWtSTMd2rKPnaZsAWFNpbf4vv2ZK7JW2nwuSypMeg/dwylauth.herokuapp.com
```

> **Note**: for security reasons, this is not a valid API key.
> Please create your own, it's free and takes less than a minute.

### 12.2 Install `auth_plug` ⬇️

Add the [auth_plug](https://github.com/dwyl/auth_plug) package to your dependencies.
In `mix.exs` file update your `deps` function and add:

```elixir
{:auth_plug, "~> 1.4.10"}
```

This dependency will create new sessions for you 
and communicate with the dwyl `auth` application.

Don't forget to:
- load your key: `source .env`
- get the dependencies: `mix deps.get`

Make sure the `AUTH_API_KEY` is accessible
before the new dependency is compiled. <br />
You can recompile the dependencies with `mix deps.compile --force`.

Now we can start adding the authentication feature.
### 12.3 Create the _Optional_ Auth Pipeline in `router.ex`

To allow [unauthenticated] "guest" users 
access to the chat
we use the `AuthPlugOptional` plug.
Read more at [optional auth](https://github.com/dwyl/auth_plug#optional-auth).

In the `router.ex` file, 
we create a new `Plug` pipeline:

```elixir
# define the new pipeline using auth_plug
pipeline :authOptional, do: plug(AuthPlugOptional)
```

Next update the `scope "/", LiveviewChatWeb do` block
to the following:

```elixir
scope "/", LiveviewChatWeb do
  pipe_through [:browser, :authOptional]

  live "/", MessageLive
  get "/login", AuthController, :login
  get "/logout", AuthController, :logout
end
```

We are now allowing authentication to be _optional_ 
for all the routes in the router.
Easy, hey? 😉

### 12.4 Create `AuthController`

Create the `AuthController`
with both `login/2` and `logout/2` functions.

Create a new file:
`lib/liveview_chat_web/controllers/auth_controller.ex`
and add the following code:

```elixir
defmodule LiveviewChatWeb.AuthController do
  use LiveviewChatWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: AuthPlug.get_auth_url(conn, "/"))
  end

  def logout(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> put_status(302)
    |> redirect(to: "/")
  end
end
```

The `login/2` function 
redirects to the dwyl auth app.
Read more about how to use the
[`AuthPlug.get_auth_url/2`](https://hexdocs.pm/auth_plug/AuthPlug.html#get_auth_url/2)
function.
Once authenticated the user will be redirected to the `/` endpoint
and a `jwt` session is created on the client.

The `logout/2` function invokes `AuthPlug.logout/1` 
which removes the (JWT) session
and redirects back to the homepage.

### 12.5 Create `on_mount/4` functions

`LiveView` provides the 
[`on_mount`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1)
callback that lets us run code 
_before_ the `mount`.
We'll use this callback to verify the `jwt` session 
and assign the `person` (`Map`)
and `loggedin` (`boolean`) values to the `socket`.

In the
`lib/liveview_chat_web/controllers/auth_controller.ex` file
add the following code 
to define two versions of `mount/4`:

```elixir
# import the assign_new function from LiveView
import Phoenix.LiveView, only: [assign_new: 3]

# pattern match on :default auth and check session has jwt
def on_mount(:default, _params, %{"jwt" => jwt} = _session, socket) do
  # verify and retrieve jwt stored data
  claims = AuthPlug.Token.verify_jwt!(jwt)

  # assigns the person and the loggedin values
  socket =
    socket
    |> assign_new(:person, fn ->
      AuthPlug.Helpers.strip_struct_metadata(claims)
    end)
    |> assign_new(:loggedin, fn -> true end)

  {:cont, socket}
end

# when jwt is not defined just returns the current socket
def on_mount(:default, _params, _session, socket) do
  socket = assign_new(socket, :loggedin, fn -> false end)
  {:cont, socket}
end
```

[assign_new/3](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#assign_new/3)
assigns a value to the socket if it doesn't exists.

Once the `on_mount/2` callback is defined,
we can call it in our 
`lib/liveview_chat_web/live/message_live.ex` 
file:

```elixir
defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message
  # run authentication on mount
  on_mount LiveviewChatWeb.AuthController
```

We now have all the logic to let people authenticate,
we just need to update our root layout file
`lib/liveview_chat_web/templates/layout/root.html.heex`
to display a `login` (or `logout`) link:

```html
<body>
  <header>
    <section class="container">
      <nav>
        <ul>
          <%= if @loggedin do %>
            <li>
              <img width="40px" src={@person.picture}/>
            </li>
            <li><%= link "logout", to: "/logout" %></li>
          <% else %>
            <li><%= link "Login", to: "/login" %></li>
          <% end %>
        </ul>
      </nav>
      <h1>LiveView Chat Example</h1>
    </section>
  </header>
  <%= @inner_content %>
</body>
```

If the person is _not_ yet `loggedin` 
we display a `login` link 
otherwise the `logout` link is displayed.

The last step 
is to display the name of the logged-in person 
in the name field of the message form.
For that we can update the form changeset 
in the `mount` function to set the name parameters:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Message.subscribe()

  # add name parameter if loggedin
  changeset =
    if socket.assigns.loggedin do
      Message.changeset(%Message{}, %{"name" => socket.assigns.person["givenName"]})
    else
      Message.changeset(%Message{}, %{})
    end

  messages = Message.list_messages() |> Enum.reverse()

  {:ok, assign(socket, messages: messages, changeset: changeset),
   temporary_assigns: [messages: []]}
end
```

You can now run the application and be able to login/logout!

![logout-button](https://user-images.githubusercontent.com/194400/145076949-e8e7cebd-9b20-4d1f-b932-68a00977acec.png)

<!-- Yes, we know we skipped step 13 ... 
 mostly to check if you're paying attention. 😜
 But also because some people find it "unlucky" ...
 https://en.wikipedia.org/wiki/13_(number)#Luck 🙄 -->
## 14. Presence

In this section we will use 
[**Phoenix Presence**](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
to display a list of people who are currently using the application.

The first step is to create the `lib/liveview_chat/presence.ex` file:

```elixir
defmodule LiveviewChat.Presence do
  use Phoenix.Presence,
    otp_app: :liveview_chat,
    pubsub_server: LiveviewChat.PubSub
end
```

Then in `lib/liveview_chat/application.ex` 
we add the newly created `Presence`
module to the list of applications 
for the supervisor to start:

```elixir
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      LiveviewChat.Repo,
      # Start the Telemetry supervisor
      LiveviewChatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveviewChat.PubSub},
      # Presence
      LiveviewChat.Presence,
      # Start the Endpoint (http/https)
      LiveviewChatWeb.Endpoint
      # Start a worker by calling: LiveviewChat.Worker.start_link(arg)
      # {LiveviewChat.Worker, arg}
    ]
...
```

We are now ready to use the Presence features in our liveview endpoint. <br />
In the `lib/liveview_chat_web/live/message_live.ex` file,
update the `mount` function with the following:


```elixir
  @presence_topic "liveview_chat_presence"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Message.subscribe()

      {id, name} =
        if socket.assigns.loggedin do
          {socket.assigns.person["id"], socket.assigns.person["givenName"]}
        else
          {socket.id, "guest"}
        end

      {:ok, _} = Presence.track(self(), @presence_topic, id, %{name: name})
      Phoenix.PubSub.subscribe(PubSub, @presence_topic)
    end

    changeset =
      if socket.assigns.loggedin do
        Message.changeset(%Message{}, %{"name" => socket.assigns.person["givenName"]})
      else
        Message.changeset(%Message{}, %{})
      end

    messages = Message.list_messages() |> Enum.reverse()

    {:ok,
     assign(socket,
       messages: messages,
       changeset: changeset,
       presence: get_presence_names()
     ), temporary_assigns: [messages: []]}
  end
```

Let's recap the main changes to the `mount/3` function:

First we create the module attribute `@presence_topic` 
to define the `topic` we'll use with the Presence functions.


The following part of the code defines a tuple 
containing an `id` of the person and their name.
 The name will default to "guest" if the person is _not_ loggedin.

```elixir
{id, name} =
    if socket.assigns.loggedin do
        {socket.assigns.person["id"], socket.assigns.person["givenName"]}
     else
        {socket.id, "guest"}
    end
```

Secondly we use the [track/4](https://hexdocs.pm/phoenix/Phoenix.Presence.html#c:track/4) function
to let Presence knows that a new client is looking at the application:

```elixir
{:ok, _} = Presence.track(self(), @presence_topic, id, %{name: name})
```

Third we use PubSub to listen to Presence changes (person joining or leaving the application):

```elixir
Phoenix.PubSub.subscribe(PubSub, @presence_topic)
```

Finally we create a new `presence` assign in the socket:

```elixir
presence: get_presence_names()
```

`get_presence_names` function will return a list of loggedin users and if any
the number of "guest" users.


Add the following code at the end of the `MessageLive` module:

```elixir
  defp get_presence_names() do
    Presence.list(@presence_topic)
    |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)
    |> group_names()
  end

  # return list of names and number of guests
  defp group_names(names) do
    loggedin_names = Enum.filter(names, fn name -> name != "guest" end)

    guest_names =
      Enum.count(names, fn name -> name == "guest" end)
      |> guest_names()

    if guest_names do
      [guest_names | loggedin_names]
    else
      loggedin_names
    end
  end

  defp guest_names(0), do: nil
  defp guest_names(1), do: "1 guest"
  defp guest_names(n), do: "#{n} guests"
```

The important function call in the code above is `Presence.list(@presence_topic)`.
The [list/1](https://hexdocs.pm/phoenix/Phoenix.Presence.html#c:list/1) function
returns the list of users using the application.
The function `group_names` and `guest_names` are just here to manipulate the
Presence data returned by `list`, see https://hexdocs.pm/phoenix/Phoenix.Presence.html#c:list/1-presence-data-structure

So far we've tracked new people using the chat page in the `mount` function and
we've been using PubSub to listen to presence changes.
The final step is to handle these changes by adding a `handle_info` function:

```elixir
def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
  { :noreply, assign(socket, presence: get_presence_names())}
end
```

> Finally, a diff of presence join and leave events 
will be sent to the clients as they happen in real-time 
with the "presence_diff" event.

The `handle_info` function catches the `presence_diff` event and reassigns to the socket
the `presence` value with the result of the `get_presence_names` function call.

To display the names we add the following in the
`lib/liveview_chat_web/templates/message/messages.html.heex`
template file:


```html
<b>People currently using the app:</b>
<ul>
   <%= for name <- @presence do %>
     <li>
       <%= name %>
     </li>
   <% end %>
</ul>
```

You should now be able to run the application and see the loggedin users
and the number of guest users.

We can test that the template has been properly updated by adding these two
tests in `test/liveview_chat_web/live/message_live_test.exs` :

```elixir
  test "1 guest online", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "1 guest"
  end

  test "2 guests online", %{conn: conn} do
    {:ok, _view, _html} = live(conn, "/")
    {:ok, view2, _html} = live(conn, "/")

    assert render(view2) =~ "2 guests"
  end
```

## 15. Tailwind CSS Stylin'

If you're new to `Tailwind`,
please see: https://github.com/dwyl/learn-tailwind

Replace the contents of `lib/liveview_chat_web/templates/layout/root.html.heex`
with:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="csrf-token" content={csrf_token_value()}>
    <%= live_title_tag assigns[:page_title] || "LiveviewChat", suffix: " · Phoenix Framework" %>
    <script defer phx-track-static type="text/javascript" src={Routes.static_path(@conn, "/assets/app.js")}></script>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body>
    <header class="bg-slate-800 w-full min-h-[15%] pt-5 pb-1 mb-2">
      <section>
        <nav>
          <div class="text-white width-[10%] float-left ml-3 -mt-5 align-middle">
          <b>People in Chat:</b>
          <ul>
            <%= for name <- @presence do %>
              <li>
                <%= name %>
              </li>
            <% end %>
          </ul>
          </div>

          <ul class="float-right mr-3">
            <%= if @loggedin do %>
              <li>
                <img width="42px" src={@person.picture} class="-mt-3"/>
              </li>
              <li class="text-white">
                <%= link "logout", to: "/logout" %>
              </li>
            <% else %>
              <li class="bg-green-600 text-white rounded-xl px-4 py-2 w-full mb-2 font-bold">
                <%= link "Login", to: "/login" %>
              </li>
            <% end %>
          </ul>
        </nav>
        <h1 class="text-3xl mb-4 text-center font-mono text-white">LiveView Chat Example</h1>
      </section>
    </header>
    <%= @inner_content %>
  </body>
</html>

```

And then replace the contents of 
`lib/liveview_chat_web/templates/message/messages.html.heex`
with:

```html
<ul id='msg-list' phx-update="append">
   <%= for message <- @messages do %>
     <li id={"msg-#{message.id}"} class="px-5">
       <small class="float-right text-xs align-middle ">
         <%= message.inserted_at %>
       </small>
       <b><%= message.name %>:</b>
       <%= message.message %>
     </li>
   <% end %>
</ul>

<footer class="fixed bottom-0 w-full bg-slate-300 pb-2 px-5 pt-2">
<.form let={f} for={@changeset} id="form" phx-submit="new_message" phx-hook="Form">

  <%= if @loggedin do %>
    <%= text_input f, :name, id: "name", value: @person.givenName,
    class: "hidden" %>
  <% else %>
    <%= text_input f, :name, id: "name", placeholder: "Name", autofocus: "true",
     class: "border p-2 w-9/12 mb-2 mt-2 mr2" %>
     <span class="italic text-2xl ml-4">or</span>
     <span class="bg-green-600 text-white rounded-xl px-4 py-2 mb-2 mt-3 float-right">
       <%= link "Login", to: "/login" %>
     </span>
    <%= error_tag f, :name %>
  <% end %>

   <%= text_input f, :message, id: "msg", placeholder: "Message",
   class: "border p-2 w-10/12  mb-2 mt-2 float-left"  %>
   <p class=" text-amber-600">
    <%= error_tag f, :message %>
   </p>
   <%= submit "Send", class: "bg-sky-600 text-white rounded-xl px-4 py-2 mt-2 float-right" %>
 </.form>
</footer>
```

You should now have a UI/layout that looks like this:

![liveview-chat-with-tailwind-css](https://user-images.githubusercontent.com/194400/174119023-bb83f5f4-867c-4bfa-a005-26b39c700137.gif)

If you have questions about any of the **`Tailwind`** classes used,
please spend 2 mins Googling 
and then if you're still stuck, 
[open an issue](https://github.com/dwyl/learn-tailwind/issues).

<br />

# What's _Next_?

If you found this example useful, 
please ⭐️ the GitHub repository
so we (_and others_) know you liked it!


Here are a few other repositories you might want to read:

- [github.com/dwyl/**phoenix-chat-example**](https://github.com/dwyl/phoenix-chat-example) 
  A chat application using Phoenix Socket
- [github.com/dwyl/**phoenix-liveview-counter-tutorial**](https://github.com/dwyl/phoenix-liveview-counter-tutorial)
- [github.com/dwyl/**phoenix-liveview-todo-list-tutorial**](https://github.com/dwyl/phoenix-liveview-todo-list-tutorial)


Any questions or suggestions? Do not hesitate to 
[open new issues](https://github.com/dwyl/phoenix-liveview-chat-example/issues)!

Thank you!

![wake-sleeping-heroku-app](https://liveview-chat-example.herokuapp.com/ping)

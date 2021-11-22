# LiveviewChat

![Libraries.io dependency status for GitHub repo](https://img.shields.io/librariesio/github/dwyl/phoenix-liveview-chat-example)

## Create Phoenix LiveView App

### Initialisation

Let's start by creating the new `liveview_chat` Phoenix application.

```sh
mix phx.new liveview_chat --no-mailer --no-dashboard
```

We don't need mail or dashboard features. You can learn more about creating
a new Phoenix application with `mix help phx.new`

Run `mix deps.get` to retreive the dependencies, then make sure you have
the `liveview_chat_dev` Postgres database available.
You should now be able to start the application with `mix phx.server`:

![phx.server](https://user-images.githubusercontent.com/6057298/142623156-ab767540-2561-43e3-bc87-1c4f89778d21.png)

### LiveView Route, Controller and Template

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
To keep the controller simple we are just retruning the {:ok, socket} tuple
without any changes and the render view call the `message.html.heex` template.
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

We are testing the `/` endpoint is accessible when the socket is not yet connected,
then when it is with the `live`function.

See also the [LiveViewTest module](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
for more information about testing and liveView.

Finally you can delete all the default generated code linked to the `PageController`.
- rm test/liveview_chat_web/controllers/page_controller_test.exs
- rm lib/liveview_chat_web/controllers/page_controller.ex
- rm test/liveview_chat_web/views/page_view_test.exs
- rm lib/liveview_chat_web/views/page_view.ex
- rm -r lib/liveview_chat_web/templates/page

You can now run the test with `mix test` command:

![image](https://user-images.githubusercontent.com/6057298/142856124-5c2d9cc6-9208-4567-b781-0b46081cfed1.png)


### Migration and Schema

Now that we have the liveView structure defined,
we can start to focus on creating messages.
The database will save the message and the name of the user.
So we can create a new schema and migration:

```sh
mix phx.gen.schema Message messages name:string message:string
```







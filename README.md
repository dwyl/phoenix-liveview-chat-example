# LiveviewChat


Let's start by creating the new `liveview_chat` Phoenix application.

```sh
mix phx.new liveview_chat --no-mailer --no-dashboard
```

We don't need mail or dashboard features. You can learn more about creating
a new Phoenix application with `mix help phx.new`

Run `mix deps.get` to retreive the dependencies, then make sure you have
the `liveview_chat_dev` Postgres database available.
You should now be able to start the application with `mix phx.server`:

[phx.server](https://user-images.githubusercontent.com/6057298/142623156-ab767540-2561-43e3-bc87-1c4f89778d21.png)

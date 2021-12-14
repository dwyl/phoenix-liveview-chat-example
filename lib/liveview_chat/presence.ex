defmodule LiveviewChat.Presence do
  use Phoenix.Presence,
    otp_app: :liveview_chat,
    pubsub_server: LiveviewChat.PubSub
end

defmodule LiveviewChat.Repo do
  use Ecto.Repo,
    otp_app: :liveview_chat,
    adapter: Ecto.Adapters.Postgres
end

defmodule LiveviewChatWeb.Router do
  use LiveviewChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveviewChatWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authOptional, do: plug(AuthPlugOptional)

  scope "/", LiveviewChatWeb do
    pipe_through [:browser, :authOptional]

    live "/", MessageLive
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
  end
end

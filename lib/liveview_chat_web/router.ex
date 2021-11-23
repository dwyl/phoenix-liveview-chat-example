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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveviewChatWeb do
    pipe_through :browser

    live "/", MessageLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveviewChatWeb do
  #   pipe_through :api
  # end
end

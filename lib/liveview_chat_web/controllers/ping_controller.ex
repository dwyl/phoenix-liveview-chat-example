defmodule LiveviewChatWeb.PingController do
  use LiveviewChatWeb, :controller

  def ping(conn, params) do
    Ping.render_pixel(conn, params)
  end
end

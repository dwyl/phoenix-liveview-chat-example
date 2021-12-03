defmodule LiveviewChatWeb.LoginController do
  use LiveviewChatWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: AuthPlug.get_auth_url(conn, "/"))
  end
end

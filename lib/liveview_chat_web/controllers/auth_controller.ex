defmodule LiveviewChatWeb.AuthController do
  use LiveviewChatWeb, :controller
  import Phoenix.LiveView, only: [assign_new: 3]

  def on_mount(:default, _params, %{"jwt" => jwt} = _session, socket) do
    socket =
      case AuthPlug.Token.verify_jwt(jwt) do
        {:ok, claims} ->
          assign_new(socket, :person, fn ->
            AuthPlug.Helpers.strip_struct_metadata(claims)
          end)

          assign_new(socket, :loggedin, fn -> true end)

        _ ->
          assign_new(socket, :loggedin, fn -> false end)
      end

    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    socket = assign_new(socket, :loggedin, fn -> false end)
    {:cont, socket}
  end

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
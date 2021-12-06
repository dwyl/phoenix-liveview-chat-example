defmodule LiveviewChatWeb.AuthLiveView do
  import Phoenix.LiveView

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
end

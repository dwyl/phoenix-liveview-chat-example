defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("message.html", assigns)
  end
end

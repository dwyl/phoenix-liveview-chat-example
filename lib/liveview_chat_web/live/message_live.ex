defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message

  def mount(_params, _session, socket) do
    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})
    {:ok, assign(socket, messages: messages, changeset: changeset)}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("message.html", assigns)
  end
end

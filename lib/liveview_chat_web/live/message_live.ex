defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})

    {:ok, assign(socket, messages: messages, changeset: changeset),
     temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("message.html", assigns)
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      :ok ->
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end
end

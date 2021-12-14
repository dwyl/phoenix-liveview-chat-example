defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message
  alias LiveviewChat.Presence
  alias LiveviewChat.PubSub
  # run authentication on mount
  on_mount LiveviewChatWeb.AuthController

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Message.subscribe()

      {id, name} =
        if socket.assigns.loggedin do
          person_id = socket.assigns.person["id"]
          person_name = socket.assigns.person["givenName"]
          {person_id, person_name}
        else
          {socket.id, "guest"}
        end

      {:ok, _} = Presence.track(self(), "liveview_chat_presence", id, %{name: name})

      Phoenix.PubSub.subscribe(PubSub, "liveview_chat_presence")
    end

    changeset =
      if socket.assigns.loggedin do
        Message.changeset(%Message{}, %{"name" => socket.assigns.person["givenName"]})
      else
        Message.changeset(%Message{}, %{})
      end

    messages = Message.list_messages() |> Enum.reverse()

    {:ok, assign(socket, messages: messages, changeset: changeset, presence: []),
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

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    # get the list of names
    names =
      Presence.list("liveview_chat_presence")
      |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)

    {
      :noreply,
      assign(socket, presence: names)
    }
  end
end

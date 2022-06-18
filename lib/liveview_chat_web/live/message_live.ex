defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message
  alias LiveviewChat.Presence
  alias LiveviewChat.PubSub
  # run authentication on mount
  on_mount LiveviewChatWeb.AuthController

  @presence_topic "liveview_chat_presence"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Message.subscribe()

      {id, name} =
        if Map.has_key?(socket.assigns, :person) do
          {socket.assigns.person.id, socket.assigns.person.givenName}
        else
          {socket.id, "guest"}
        end

      {:ok, _} = Presence.track(self(), @presence_topic, id, %{name: name})
      Phoenix.PubSub.subscribe(PubSub, @presence_topic)
    end

    changeset =
      if Map.has_key?(socket.assigns, :person) do
        Message.changeset(%Message{}, %{"name" => socket.assigns.person.givenName})
      else
        Message.changeset(%Message{}, %{})
      end

    messages = Message.list_messages() |> Enum.reverse()

    {:ok,
     assign(socket,
       messages: messages,
       changeset: changeset,
       presence: get_presence_names()
     ), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("messages.html", assigns)
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

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {
      :noreply,
      assign(socket, presence: get_presence_names())
    }
  end

  defp get_presence_names() do
    Presence.list(@presence_topic)
    |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)
    |> group_names()
  end

  # return list of names and number of guests
  defp group_names(names) do
    loggedin_names = Enum.filter(names, fn name -> name != "guest" end)

    guest_names =
      Enum.count(names, fn name -> name == "guest" end)
      |> guest_names()

    if guest_names do
      [guest_names | loggedin_names]
    else
      loggedin_names
    end
  end

  defp guest_names(0), do: nil
  defp guest_names(1), do: "1 guest"
  defp guest_names(n), do: "#{n} guests"
end

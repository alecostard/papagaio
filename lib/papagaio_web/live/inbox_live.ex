defmodule PapagaioWeb.InboxLive do
  use Phoenix.LiveView

  alias Papagaio.Webhooks

  def render(assigns) do
    ~H"""
    <%= for w <- @webhooks  do %>
      <details>
        <summary> <%= w.path %> <%= w.inserted_at %> </summary>
        <pre><%= Jason.encode!(w.body, pretty: true) %></pre>
      </details>
    <% end %>
    """
  end

  def mount(%{"inbox_id" => inbox_id}, _session, socket) do
    if connected?(socket), do: Webhooks.subscribe_to_inbox(inbox_id)

    webhooks = Webhooks.list_webhooks(inbox_id)
    {:ok, assign(socket, :webhooks, webhooks)}
  end

  def handle_info({:webhook_received, webhook}, socket) do
    {:noreply, update(socket, :webhooks, &[webhook | &1])}
  end
end

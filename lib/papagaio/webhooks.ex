defmodule Papagaio.Webhooks do
  @moduledoc """
  The webhooks context.

  This module contains functions for handling webhooks and inboxes.
  """

  alias Papagaio.Webhooks.Webhook
  alias Papagaio.Repo

  def create_webhook(inbox_id, path, body) do
    changeset = Webhook.changeset(%Webhook{}, %{inbox_id: inbox_id, path: path, body: body})

    with {:ok, webhook} <- Repo.insert(changeset) do
      Phoenix.PubSub.broadcast(Papagaio.PubSub, "inbox:#{inbox_id}", {:webhook_received, webhook})
      {:ok, webhook}
    end
  end

  def list_webhooks(inbox_id) do
    import Ecto.Query

    Repo.all(from w in Webhook, where: w.inbox_id == ^inbox_id, order_by: [desc: :inserted_at])
  end

  def subscribe_to_inbox(inbox_id) do
    Phoenix.PubSub.subscribe(Papagaio.PubSub, "inbox:#{inbox_id}")
  end
end

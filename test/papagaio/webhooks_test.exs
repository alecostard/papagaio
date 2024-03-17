defmodule Papagaio.WebhooksTest do
  alias Papagaio.Webhooks.Webhook
  use Papagaio.DataCase

  alias Papagaio.Webhooks

  describe "create_webhooks/3" do
    alias Webhooks.Webhook

    test "with valid data records a webhook" do
      inbox_id = Ecto.UUID.generate()
      path = "/some/path"
      body = %{"key1" => "value1", "key2" => ["val2a", "val2b"]}

      assert {:ok, %Webhook{} = webhook} = Webhooks.create_webhook(inbox_id, path, body)

      refute is_nil(webhook.id)
      assert webhook.inbox_id == inbox_id
      assert webhook.path == path
      assert webhook.body == body
    end

    test "with valid data broadcasts a webhook_received message to the specific inbox topic" do
      inbox_id = Ecto.UUID.generate()
      path = "/some/path"
      body = %{"key1" => "value1", "key2" => ["val2a", "val2b"]}

      Webhooks.subscribe_to_inbox(inbox_id)
      assert {:ok, %Webhook{} = webhook} = Webhooks.create_webhook(inbox_id, path, body)

      assert_receive {:webhook_received, ^webhook}
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Webhooks.create_webhook("invalid_inbox", "", "invalid_body")
    end
  end

  describe "list_webhooks/1" do
    test "list all webhooks from an specific inbox in reverse chronologic order" do
      inbox1 = Ecto.UUID.generate()
      inbox2 = Ecto.UUID.generate()
      {:ok, wh1} = Webhooks.create_webhook(inbox1, "/path1a", %{})
      {:ok, wh2} = Webhooks.create_webhook(inbox1, "/path1b", %{})
      {:ok, wh3} = Webhooks.create_webhook(inbox2, "/path2a", %{})
      {:ok, wh4} = Webhooks.create_webhook(inbox1, "/path1a", %{})

      assert [^wh4, ^wh2, ^wh1] = Webhooks.list_webhooks(inbox1)
      assert [^wh3] = Webhooks.list_webhooks(inbox2)
      assert [] = Webhooks.list_webhooks(Ecto.UUID.generate())
    end
  end

  describe "subscribe_to_inbox/1" do
    test "receives messages for the specific inbox for webhooks received after subscribing" do
      inbox_id = Ecto.UUID.generate()

      {:ok, _wh1} = Webhooks.create_webhook(inbox_id, "/", %{})

      Webhooks.subscribe_to_inbox(inbox_id)

      {:ok, wh2} = Webhooks.create_webhook(inbox_id, "/", %{})
      assert_receive {:webhook_received, ^wh2}

      {:ok, wh3} = Webhooks.create_webhook(inbox_id, "/", %{})
      {:ok, wh4} = Webhooks.create_webhook(inbox_id, "/", %{})
      {:ok, wh5} = Webhooks.create_webhook(inbox_id, "/", %{})
      assert_receive {:webhook_received, ^wh3}

      assert {:messages, [{:webhook_received, ^wh4}, {:webhook_received, ^wh5}]} =
               Process.info(self(), :messages)
    end
  end
end

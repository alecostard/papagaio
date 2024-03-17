defmodule PapagaioWeb.WebhookController do
  use PapagaioWeb, :controller

  alias Papagaio.Webhooks

  def create(conn, params) do
    %{"inbox_id" => inbox_id, "webhook_path" => webhook_path} = params
    path = "/" <> Enum.join(webhook_path, "/")
    body = conn.body_params

    case Webhooks.create_webhook(inbox_id, path, body) do
      {:ok, _} -> send_resp(conn, :created, "")
      {:error, _} -> send_resp(conn, :unprocessable_entity, "")
    end
  end
end

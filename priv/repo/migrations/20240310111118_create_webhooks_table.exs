defmodule Papagaio.Repo.Migrations.CreateWebhooksTable do
  use Ecto.Migration

  def change do
    create table("webhooks", primary_key: false) do
      add :id, :uuid, primary_key: true

      timestamps()

      add :inbox_id, :uuid, null: false
      add :path, :text, null: false
      add :body, :map, null: false
    end
  end
end

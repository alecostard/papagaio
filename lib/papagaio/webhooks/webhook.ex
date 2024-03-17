defmodule Papagaio.Webhooks.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "webhooks" do
    field :inbox_id, Ecto.UUID
    field :path, :string
    field :body, :map

    timestamps()
  end

  def changeset(%__MODULE__{} = webhook, attrs) do
    webhook
    |> cast(attrs, [:inbox_id, :path, :body])
    |> validate_required([:inbox_id, :path, :body])
  end
end

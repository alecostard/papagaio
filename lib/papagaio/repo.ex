defmodule Papagaio.Repo do
  use Ecto.Repo,
    otp_app: :papagaio,
    adapter: Ecto.Adapters.SQLite3
end

defmodule PapagaioWeb.WebhookControllerTest do
  use PapagaioWeb.ConnCase

  describe "POST /inbox/:inbox_id/webhook/*webhook_path" do
    test "creates a new webhook", %{conn: conn} do
      inbox_id = Ecto.UUID.generate()

      assert "" =
               conn
               |> post(~p"/inbox/#{inbox_id}/webhook/some/webhook/path")
               |> response(201)
    end
  end
end

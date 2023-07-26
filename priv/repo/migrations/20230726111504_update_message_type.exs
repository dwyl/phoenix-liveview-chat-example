defmodule LiveviewChat.Repo.Migrations.UpdateMessageType do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :message, :text
    end
  end
end

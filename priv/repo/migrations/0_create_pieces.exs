defmodule Chess.Repo.Migrations.CreatePieces do
  use Ecto.Migration

  def change do
    create table(:pieces) do
      add :type, :string
      add :origin, :binary # coordinate tuple
      add :owner_id, references(:users, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime)
    end

#    create index(:pieces, [:user])
  end
end

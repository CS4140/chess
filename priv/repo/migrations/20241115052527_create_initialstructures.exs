defmodule Chess.Repo.Migrations.CreateInitialstructures do
  use Ecto.Migration

  def change do
    create table(:initialstructures) do
      add :board, :binary
      add :user, references(:users, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:initialstructures, [:user])
  end
end

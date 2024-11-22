defmodule Chess.Repo.Migrations.CreateStartconfigurations do
  use Ecto.Migration

  def change do
    create table(:startconfigurations) do
      add :board, :binary
      add :user, references(:users, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:startconfigurations, [:user])
  end
end

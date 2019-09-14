defmodule Vtb.Repo.Migrations.AddStateToVotes do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :state, :string, null: false, default: "ongoing"
      add :finished_at, :utc_datetime
    end

    create index(:votes, :state)
  end
end

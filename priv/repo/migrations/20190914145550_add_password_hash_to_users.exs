defmodule Vtb.Repo.Migrations.AddPasswordHashToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string, null: false
      add :jwt, :string
    end
  end
end

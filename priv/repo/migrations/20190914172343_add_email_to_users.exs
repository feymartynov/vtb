defmodule Vtb.Repo.Migrations.AddEmailToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :text, null: false
    end
  end
end

defmodule Vtb.Repo.Migrations.AddUserEmailIndex do
  use Ecto.Migration

  def up do
    execute "CREATE UNIQUE INDEX users_email_idx ON users ((lower(email)))"
  end

  def down do
    execute "DROP UNIQUE_INDEX users_email_idx"
  end
end

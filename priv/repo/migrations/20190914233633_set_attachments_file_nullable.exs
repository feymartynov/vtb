defmodule Vtb.Repo.Migrations.SetAttachmentsFileNullable do
  use Ecto.Migration

  def change do
    alter table(:attachments) do
      modify :file, :text, null: true
    end
  end
end

defmodule Vtb.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table(:position) do
      add :title, :text, null: false
      add :weight, :integer, null: false, default: 1
    end

    create table(:users) do
      add :first_name, :text
      add :middle_name, :text
      add :last_name, :text
      add :position_id, references(:position)
      add :avatar, :text
      timestamps()
    end

    create index(:users, :position_id)

    create table(:votes) do
      add :title, :text, null: false
      add :description, :text
      add :deadline, :utc_datetime
      add :creator_id, references(:users)
      timestamps()
    end

    create index(:votes, :creator_id)

    create table(:participants) do
      add :vote_id, references(:votes), null: false
      add :user_id, references(:users), null: false
    end

    create unique_index(:participants, [:vote_id, :user_id])
    create index(:participants, :vote_id)
    create index(:participants, :user_id)

    create table(:topics) do
      add :vote_id, references(:votes), null: false
      add :title, :text, null: false
      timestamps()
    end

    create index(:topics, :vote_id)

    create table(:voices) do
      add :topic_id, references(:topics), null: false
      add :user_id, references(:users), null: false
      add :decision, :integer, null: false
      timestamps()
    end

    create unique_index(:voices, [:topic_id, :user_id])
    create index(:voices, :topic_id)
    create index(:voices, :user_id)

    create table(:messages) do
      add :topic_id, references(:topics), null: false
      add :author_id, references(:users), null: false
      add :text, :text, null: false
      timestamps()
    end

    create index(:messages, :author_id)

    create table(:attachments) do
      add :file, :text, null: false
      add :title, :text, null: false
    end

    create table(:vote_attachments) do
      add :vote_id, references(:votes)
      add :attachment_id, references(:attachments)
    end

    create index(:vote_attachments, :vote_id)
    create index(:vote_attachments, :attachment_id)

    create table(:topic_attachments) do
      add :topic_id, references(:topics)
      add :attachment_id, references(:attachments)
    end

    create index(:topic_attachments, :topic_id)
    create index(:topic_attachments, :attachment_id)

    create table(:message_attachments) do
      add :message_id, references(:messages)
      add :attachment_id, references(:attachments)
    end

    create index(:message_attachments, :message_id)
    create index(:message_attachments, :attachment_id)
  end
end

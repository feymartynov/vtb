defmodule Vtb.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :title, :string
    field :description, :string
    field :state, :string, default: "ongoing"
    field :deadline, :utc_datetime
    field :finished_at, :utc_datetime
    timestamps()

    belongs_to :creator, Vtb.User
    has_many :topics, Vtb.Topic
    has_many :participants, Vtb.Participant
    has_many :participant_users, through: [:participants, :user]
    many_to_many :attachments, Vtb.Attachment, join_through: "vote_attachments"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title, :description, :deadline])
    |> cast_assoc(:topics)
    |> cast_assoc(:participants)
    |> cast_assoc(:attachments)
    |> validate_required([:title])
  end
end

defmodule Vtb.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :title, :string
    field :description, :string
    field :deadline, :utc_datetime
    timestamps()

    belongs_to :creator, Vtb.User
    has_many :topics, Vtb.Topic
    many_to_many :participants, Vtb.User, join_through: "participants"
    many_to_many :attachments, Vtb.Attachment, join_through: "vote_attachments"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title, :description, :deadline])
    |> cast_assoc(:attachments)
    |> validate_required([:title])
  end
end

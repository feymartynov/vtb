defmodule Vtb.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topic" do
    field :title, :string
    timestamps()

    belongs_to :vote, Vtb.Vote
    has_many :voices, Vtb.Voice
    has_many :messages, Vtb.Message
    many_to_many :attachments, Vtb.Attachment, join_through: "topic_attachments"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title, :vote_id])
    |> cast_assoc(:attachments)
    |> foreign_key_constraint(:vote_id)
  end
end

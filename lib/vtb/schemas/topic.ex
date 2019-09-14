defmodule Vtb.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topic" do
    field :title, :string
    timestamps()

    belongs_to :vote, Vtb.Vote
    has_many :voices, Vtb.Voice
    many_to_many :attachments, Vtb.Attachment, join_through: "topic_attachments"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title])
    |> cast_assoc(:attachments)
  end
end

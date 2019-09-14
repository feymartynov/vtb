defmodule Vtb.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :text, :string
    timestamps()

    belongs_to :topic, Vtb.Topic
    belongs_to :author, Vtb.User
    many_to_many :attachments, Vtb.Attachment, join_through: "message_attachments"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:text, :topic_id])
    |> cast_assoc(:attachments)
    |> foreign_key_constraint(:topic_id)
  end
end

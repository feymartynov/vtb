defmodule Vtb.Topic do
  use Ecto.Schema

  schema "topic" do
    field :title, :string
    timestamps()

    has_many :voices, Vtb.Voice
    many_to_many :attachments, Vtb.Attachment, join_through: :topic_attachments
  end
end

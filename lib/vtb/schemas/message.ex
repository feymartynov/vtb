defmodule Vtb.Message do
  use Ecto.Schema

  schema "messages" do
    field :text, :string
    timestamps()

    belongs_to :topic, Vtb.Topic
    belongs_to :author, Vtb.User
    many_to_many :attachments, Vtb.Attachment, join_through: :message_attachments
  end
end

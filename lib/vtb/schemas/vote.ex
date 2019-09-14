defmodule Vtb.Vote do
  use Ecto.Schema

  schema "votes" do
    field :title, :string
    field :description, :string
    field :deadline, :utc_datetime
    timestamps()

    belongs_to :creator, Vtb.User
    has_many :topics, Vtb.Topic
    many_to_many :participants, Vtb.User, join_through: :participants
    many_to_many :attachments, Vtb.Attachment, join_through: :vote_attachments
  end
end

defmodule Vtb.User do
  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :avatar, __MODULE__.Avatar.Type
    timestamps()

    belongs_to :position, Vtb.Position
    many_to_many :votes, Vtb.Vote, join_through: :participants
  end
end

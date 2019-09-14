defmodule Vtb.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :avatar, __MODULE__.Avatar.Type
    timestamps()

    belongs_to :position, Vtb.Position
    many_to_many :votes, Vtb.Vote, join_through: "participants"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:first_name, :middle_name, :last_name, :position_id])
    |> cast_attachments(attrs, [:avatar])
    |> foreign_key_constraint(:position_id)
  end
end

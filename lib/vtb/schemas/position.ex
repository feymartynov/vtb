defmodule Vtb.Position do
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :title, :string
    field :weight, :float, default: 1.0
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title, :weight])
    |> validate_required([:title])
    |> validate_number(:weight, greater_than_or_equal_to: 0)
  end
end

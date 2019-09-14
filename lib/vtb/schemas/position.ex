defmodule Vtb.Position do
  use Ecto.Schema

  schema "positions" do
    field :title, :string
    field :weight, :integer
  end
end

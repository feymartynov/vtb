defmodule Vtb.Voice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "voices" do
    field :decision, :integer

    belongs_to :voter, Vtb.User
    belongs_to :topic, Vtb.Topic
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:topic_id, :decision])
    |> validate_inclusion(:decision, [-1, 0, 1])
    |> foreign_key_constraint(:topic_id)
  end
end

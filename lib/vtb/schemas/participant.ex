defmodule Vtb.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    belongs_to :vote, Vtb.Vote
    belongs_to :user, Vtb.User
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:vote_id, :user_id])
    |> foreign_key_constraint(:vote_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :participants_vote_id_user_id_index)
  end
end

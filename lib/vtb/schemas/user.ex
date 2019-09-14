defmodule Vtb.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :avatar, __MODULE__.Avatar.Type
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:jwt, :string)
    timestamps()

    belongs_to :position, Vtb.Position
    many_to_many :votes, Vtb.Vote, join_through: "participants"
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:first_name, :middle_name, :last_name, :position_id, :password])
    |> cast_attachments(attrs, [:avatar])
    |> foreign_key_constraint(:position_id)
    |> validate_required([:password])
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end

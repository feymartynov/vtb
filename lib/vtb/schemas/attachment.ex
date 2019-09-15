defmodule Vtb.Attachment do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Vtb.Repo

  schema "attachments" do
    field :title, :string
    field :file, __MODULE__.File.Type
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end

  def add_files(parent_schema, nil), do: {:ok, parent_schema}
  def add_files(parent_schema, []), do: {:ok, parent_schema}

  def add_files(parent_schema, attachemnt_attrs) do
    result =
      parent_schema.attachments
      |> Stream.zip(attachemnt_attrs)
      |> Enum.reduce_while(:ok, fn {attachment, attrs}, _ ->
        attachment
        |> cast(attrs, [])
        |> cast_attachments(attrs, [:file])
        |> validate_required([:file])
        |> Repo.update()
        |> case do
          {:ok, _} -> {:cont, :ok}
          other -> {:halt, other}
        end
      end)

    with :ok <- result, do: parent_schema |> Repo.preload(:attachments, force: true)
  end
end

defmodule Vtb.Attachment do
  defmodule Definition do
    use Arc.Definition
    use Arc.Ecto.Definition

    def storage_dir(_, {_, %{id: id}}) when not is_nil(id) do
      "uploads/attachments/#{id}"
    end
  end

  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "attachments" do
    field :title, :string
    field :file, Definition.Type
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:title])
    |> cast_attachments(attrs, [:file])
    |> validate_required([:title, :file])
  end
end

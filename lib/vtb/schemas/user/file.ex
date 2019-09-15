defmodule Vtb.Attachment.File do
  use Arc.Definition
  use Arc.Ecto.Definition

  def storage_dir(_, {_, %{id: id}}) when not is_nil(id) do
    "uploads/attachments/#{id}"
  end
end

defmodule VtbWeb.Schema.Attachment do
  use Absinthe.Schema.Notation

  @desc "Attachment"
  object :attachment do
    field :title, non_null(:string)

    field :url, non_null(:string),
      resolve: fn attachment, _, _ ->
        {:ok, Vtb.Attachment.File.url({attachment.file, attachment}, :original, signed: true)}
      end
  end

  @desc "Attachment upload"
  input_object :attachment_params do
    field :title, non_null(:string)
    field :file, non_null(:upload)
  end
end

defmodule VtbWeb.Schema.Message do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.MessageResolver

  @desc "Message"
  object :message do
    field :id, non_null(:id)
    field :text, non_null(:string)
    field :inserted_at, non_null(:timestamp)
    field :topic, non_null(:topic), resolve: dataloader(DB)
    field :author, non_null(:user), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :message_mutations do
    @desc "Create message"
    field :create_message, :message do
      arg(:topic_id, non_null(:integer))
      arg(:text, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(&MessageResolver.create/3)
    end
  end
end

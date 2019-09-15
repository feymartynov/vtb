defmodule VtbWeb.Schema.Topic do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.TopicResolver

  @desc "Topic"
  object :topic do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :inserted_at, non_null(:timestamp)
    field :vote, non_null(:vote), resolve: dataloader(DB)
    field :voices, list_of(:voice), resolve: dataloader(DB)
    field :messages, list_of(:message), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :topic_mutations do
    @desc "Create topic"
    field :create_topic, :topic do
      arg(:vote_id, non_null(:integer))
      arg(:title, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(&TopicResolver.create/3)
    end
  end
end

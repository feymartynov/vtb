defmodule VtbWeb.Schema.Vote do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.VoteResolver

  @desc "Vote"
  object :vote do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :state, non_null(:string)
    field :deadline, :timestamp
    field :finish_date, :timestamp
    field :inserted_at, non_null(:timestamp)
    field :creator, non_null(:user), resolve: dataloader(DB)
    field :participants, list_of(:user), resolve: dataloader(DB)
    field :topics, list_of(:topic), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :vote_queries do
    @desc "List votes"
    field :list_votes, non_null(list_of(non_null(:vote))) do
      resolve(&VoteResolver.list/3)
    end
  end

  input_object :topic_params do
    field(:vote_id, non_null(:integer))
    field(:title, non_null(:string))
    field(:attachments, list_of(:attachment_params))
  end

  object :vote_mutations do
    @desc "Create vote"
    field :create_vote, :vote do
      arg(:title, non_null(:string))
      arg(:description, :string)
      arg(:deadline, :timestamp)
      arg(:topics, list_of(:topic_params))
      arg(:attachments, list_of(:attachment_params))

      resolve(&VoteResolver.create/3)
    end

    @desc "Cancel vote"
    field :cancel_vote, :vote do
      arg(:vote_id, :integer)

      resolve(&VoteResolver.cancel/3)
    end
  end
end

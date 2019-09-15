defmodule VtbWeb.Schema.Participant do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.ParticipantResolver

  @desc "Participant"
  object :participant do
    field :vote, non_null(:vote), resolve: dataloader(DB)
    field :user, non_null(:user), resolve: dataloader(DB)
  end

  object :participant_mutations do
    @desc "Create participant"
    field :create_participant, :participant do
      arg(:vote_id, non_null(:integer))
      arg(:user_id, non_null(:integer))

      resolve(&ParticipantResolver.create/3)
    end
  end
end

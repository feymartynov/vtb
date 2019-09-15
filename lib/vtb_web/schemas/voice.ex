defmodule VtbWeb.Schema.Voice do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.VoiceResolver

  @desc "Voice"
  object :voice do
    field :decision, non_null(:integer)
    field :inserted_at, non_null(:timestamp)
    field :voter, non_null(:user), resolve: dataloader(DB)
    field :topic, non_null(:topic), resolve: dataloader(DB)
  end

  object :voice_mutations do
    @desc "Create voice"
    field :create_voice, :voice do
      arg(:topic_id, :integer)
      arg(:decision, :integer)

      resolve(&VoiceResolver.create/3)
    end
  end
end

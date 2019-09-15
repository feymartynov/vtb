defmodule VtbWeb.VoiceResolver do
  alias Vtb.{User, Voter}

  def create(_root, args, %{context: %{current_user: %User{id: user_id}}}) do
    Voter.vote(args.topic_id, user_id, args.decision)
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

defmodule VtbWeb.ParticipantResolver do
  alias Vtb.{Repo, User, Participant}

  def create(_root, args, %{context: %{current_user: %User{}}}) do
    %Participant{} |> Participant.changeset(args) |> Repo.insert()
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

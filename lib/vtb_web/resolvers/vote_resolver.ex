defmodule VtbWeb.VoteResolver do
  alias Vtb.{Repo, User, Vote, Attachment}

  def list(_root, _args, %{context: %{current_user: %User{}}}) do
    {:ok, Vote |> Repo.all()}
  end

  def list(_root, _args, _info) do
    {:error, "Unauthorized"}
  end

  def create(_root, args, %{context: %{current_user: %User{} = user}}) do
    Repo.transaction(fn ->
      result = %Vote{creator_id: user.id} |> Vote.changeset(args) |> Repo.insert()
      with {:ok, vote} <- result, do: vote |> Attachment.add_files(args[:attachments])
    end)
    |> case do
      {:ok, result} -> result
      other -> other
    end
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end

  def cancel(_root, %{vote_id: id}, %{context: %{current_user: %User{}}}) do
    case Vote |> Repo.get(id) do
      %Vote{} = vote ->
        vote |> Ecto.Changeset.change(%{state: "cancelled"}) |> Repo.update()

      nil ->
        {:error, "Not found"}
    end
  end

  def cancel(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

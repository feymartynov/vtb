defmodule VtbWeb.TopicResolver do
  alias Vtb.{Repo, User, Topic, Attachment}

  def create(_root, args, %{context: %{current_user: %User{}}}) do
    Repo.transaction(fn ->
      with {:ok, topic} <- %Topic{} |> Topic.changeset(args) |> Repo.insert() do
        topic |> Attachment.add_files(args.attachments)
      end
    end)
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

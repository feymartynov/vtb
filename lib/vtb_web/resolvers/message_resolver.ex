defmodule VtbWeb.MessageResolver do
  alias Vtb.{Repo, User, Message, Attachment}

  def create(_root, args, %{context: %{current_user: %User{} = user}}) do
    Repo.transaction(fn ->
      result = %Message{author_id: user.id} |> Message.changeset(args) |> Repo.insert()
      with {:ok, message} <- result, do: message |> Attachment.add_files(args.attachments)
    end)
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

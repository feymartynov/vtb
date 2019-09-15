defmodule VtbWeb.UserResolver do
  alias Vtb.{Repo, User}

  def list(_root, _args, _info) do
    {:ok, User |> Repo.all()}
  end

  def create(_root, args, _info) do
    %User{} |> User.registration_changeset(args) |> Repo.insert()
  end

  def update(_root, args, %{context: %{current_user: %User{} = user}}) do
    user |> User.profile_changeset(args) |> Repo.update()
  end

  def update(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

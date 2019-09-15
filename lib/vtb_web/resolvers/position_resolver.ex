defmodule VtbWeb.PositionResolver do
  alias Vtb.{Repo, User, Position}

  def list(_root, _args, _info) do
    {:ok, Position |> Repo.all()}
  end

  def create(_root, args, %{context: %{current_user: %User{}}}) do
    %Position{} |> Position.changeset(args) |> Repo.insert()
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end
end

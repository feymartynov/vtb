defmodule VtbWeb.Auth do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query

  alias Vtb.{Repo, User}

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} -> conn |> put_private(:absinthe, %{context: context})
      _ -> conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> jwt] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(jwt),
         do: {:ok, %{current_user: current_user, jwt: jwt}}
  end

  defp authorize(jwt) do
    case User |> where(jwt: ^jwt) |> Repo.one() do
      user = %User{} -> {:ok, user}
      nil -> {:error, "Invalid authorization token"}
    end
  end
end

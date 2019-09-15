defmodule VtbWeb.SessionResolver do
  alias Vtb.{Repo, User}

  def login(_root, %{email: email, password: password}, _info) do
    login_with_email_pass = fn email, given_pass ->
      user = User |> Repo.get_by(email: String.downcase(email))

      cond do
        user && Bcrypt.verify_pass(given_pass, user.password_hash) -> {:ok, user}
        user -> {:error, "Incorrect login credentials"}
        true -> {:error, "User not found"}
      end
    end

    with {:ok, user} <- login_with_email_pass.(email, password),
         {:ok, jwt, _} <- Vtb.Guardian.encode_and_sign(user),
         {:ok, _} <- user |> Ecto.Changeset.cast(%{jwt: jwt}, [:jwt]) |> Repo.update(),
         do: {:ok, %{jwt: jwt}}
  end

  def current_user(_root, _args, %{context: %{current_user: %User{} = user}}) do
    {:ok, user}
  end

  def current_user(_root, _args, _info) do
    {:error, "Unauthorized"}
  end

  def logout(_root, _args, %{context: %{current_user: %User{} = user}}) do
    user |> Ecto.Changeset.cast(%{jwt: nil}, [:jwt]) |> Repo.update()
  end

  def logout(_root, _args, _info) do
    {:error, "Please log in first!"}
  end
end

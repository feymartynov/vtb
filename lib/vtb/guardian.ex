defmodule Vtb.Guardian do
  use Guardian, otp_app: :vtb
  alias Vtb.{Repo, User}

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(claims) do
    id = claims["sub"] |> String.to_integer()

    case User |> Repo.get(id) do
      user = %User{} -> {:ok, user}
      nil -> {:error, "User with id `#{id}` not found"}
    end
  end
end

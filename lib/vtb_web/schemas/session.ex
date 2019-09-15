defmodule VtbWeb.Schema.Session do
  use Absinthe.Schema.Notation
  alias VtbWeb.SessionResolver

  @desc "Session"
  object :session do
    field :jwt, non_null(:string)
  end

  object :session_queries do
    @desc "Show current user"
    field :current_user, non_null(:user) do
      resolve(&SessionResolver.current_user/3)
    end
  end

  object :session_mutations do
    @desc "Login"
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&SessionResolver.login/3)
    end

    @desc "Logout"
    field :logout, :user do
      arg(:id, non_null(:id))

      resolve(&SessionResolver.logout/3)
    end
  end
end

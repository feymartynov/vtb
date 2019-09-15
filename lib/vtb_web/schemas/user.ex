defmodule VtbWeb.Schema.User do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias VtbWeb.UserResolver

  @desc "User"
  object :user do
    field :id, non_null(:id)
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :position, non_null(:position), resolve: dataloader(DB)

    field :avatar, :string,
      resolve: fn user, _, _ ->
        {:ok, user.avatar && Vtb.User.Avatar.url({user.avatar, user}, :thumb, signed: true)}
      end
  end

  object :user_queries do
    @desc "List users"
    field :list_users, non_null(list_of(non_null(:user))) do
      resolve(&UserResolver.list/3)
    end
  end

  object :user_mutations do
    @desc "Create user"
    field :create_user, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:position_id, non_null(:integer))
      arg(:first_name, :string)
      arg(:middle_name, :string)
      arg(:last_name, :string)

      resolve(&UserResolver.create/3)
    end

    @desc "Update profile"
    field :update_profile, :user do
      arg(:email, :string)
      arg(:password, :string)
      arg(:first_name, :string)
      arg(:middle_name, :string)
      arg(:last_name, :string)
      arg(:position_id, :integer)
      arg(:avatar, :upload)

      resolve(&UserResolver.update/3)
    end
  end
end

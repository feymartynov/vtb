defmodule VtbWeb.Schema do
  use Absinthe.Schema
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import_types(Absinthe.Plug.Types)

  alias Vtb.{Repo, Position, User, Vote, Participant, Topic, Message, Voice}

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(DB, Dataloader.Ecto.new(Repo, query: & &1))

    ctx |> Map.put(:loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  #########
  # Types #
  #########

  scalar :timestamp do
    description("Timestmap")
    parse(&DateTime.from_iso8601(&1))
    serialize(&DateTime.to_iso8601(&1))
  end

  scalar :avatar do
    description("Avatar")
    parse(&Vtb.User.Avatar.parse/1)
    serialize(&Vtb.User.Avatar.serialize/1)
  end

  ###########
  # Objects #
  ###########

  object :position do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :weight, non_null(:integer)
  end

  object :user do
    field :id, non_null(:id)
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :position, :position
    field :avatar, :avatar
  end

  object :vote do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :deadline, :timestamp
    field :inserted_at, non_null(:timestamp)
    field :creator, non_null(:user), resolve: dataloader(DB)
    field :participants, list_of(:user), resolve: dataloader(DB)
    field :topics, list_of(:topic), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :participant do
    field :vote, non_null(:vote), resolve: dataloader(DB)
    field :user, non_null(:user), resolve: dataloader(DB)
  end

  object :topic do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :inserted_at, non_null(:timestamp)
    field :vote, non_null(:vote), resolve: dataloader(DB)
    field :voices, list_of(:voice), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :message do
    field :id, non_null(:id)
    field :text, non_null(:string)
    field :inserted_at, non_null(:timestamp)
    field :topic, non_null(:topic), resolve: dataloader(DB)
    field :author, non_null(:user), resolve: dataloader(DB)
    field :attachments, list_of(:attachment), resolve: dataloader(DB)
  end

  object :voice do
    field :decision, non_null(:integer)
    field :inserted_at, non_null(:timestamp)
    field :voter, non_null(:user), resolve: dataloader(DB)
    field :topic, non_null(:topic), resolve: dataloader(DB)
  end

  object :attachment do
    field :title, non_null(:string)
    field :url, non_null(:string)
  end

  ###########
  # Queries #
  ###########

  query do
    field :list_positions, non_null(list_of(non_null(:position))) do
      resolve(fn _root, _args, _info ->
        Position |> Repo.all()
      end)
    end

    field :list_users, non_null(list_of(non_null(:user))) do
      resolve(fn _root, _args, _info ->
        User |> Repo.all()
      end)
    end

    field :list_votes, non_null(list_of(non_null(:vote))) do
      resolve(fn _root, _args, _info ->
        Vote |> Repo.all()
      end)
    end
  end

  #############
  # Mutations #
  #############

  @desc "Attachment upload"
  input_object :attachment_params do
    field :title, non_null(:string)
    field :file, non_null(:upload)
  end

  mutation do
    @desc "Create position"
    field :create_position, :position do
      arg(:title, non_null(:string))
      arg(:weight, :integer)

      resolve(fn _root, args, _info ->
        %Position{} |> Position.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create user"
    field :create_user, :user do
      arg(:first_name, :string)
      arg(:middle_name, :string)
      arg(:last_name, :string)
      arg(:avatar, :upload)

      resolve(fn _root, args, _info ->
        %User{} |> User.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create vote"
    field :create_vote, :vote do
      arg(:title, non_null(:string))
      arg(:description, non_null(:string))
      arg(:deadline, :timestamp)
      arg(:attachments, list_of(:attachment_params))

      resolve(fn _root, args, _info ->
        %Vote{} |> Vote.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create participant"
    field :create_participant, :participant do
      arg(:vote_id, non_null(:integer))
      arg(:user_id, non_null(:integer))

      resolve(fn _root, args, _info ->
        %Participant{} |> Participant.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create topic"
    field :create_topic, :topic do
      arg(:vote_id, non_null(:integer))
      arg(:title, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(fn _root, args, _info ->
        %Topic{} |> Topic.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create message"
    field :create_message, :message do
      arg(:topic_id, non_null(:integer))
      arg(:text, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(fn _root, args, _info ->
        %Message{} |> Message.changeset(args) |> Repo.insert()
      end)
    end

    @desc "Create voice"
    field :create_voice, :voice do
      arg(:topic_id, :integer)
      arg(:decision, :integer)

      resolve(fn _root, args, _info ->
        %Voice{} |> Voice.changeset(args) |> Repo.insert()
      end)
    end
  end
end

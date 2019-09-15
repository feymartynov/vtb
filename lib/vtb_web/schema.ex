defmodule VtbWeb.Schema do
  use Absinthe.Schema
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import_types(Absinthe.Plug.Types)
  import Ecto.Query

  alias Vtb.{Repo, Position, User, Vote, Participant, Topic, Message, Attachment, Voter}

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(DB, Dataloader.Ecto.new(Repo, query: &scope/2))

    ctx |> Map.put(:loader, loader)
  end

  def scope(query, Topic), do: query |> order_by([t], t.inserted_at)
  def scope(query, Message), do: query |> order_by([m], m.inserted_at)
  def scope(query, _), do: query

  scalar :timestamp, name: "Timestamp" do
    parse(&NaiveDateTime.from_iso8601(&1))
    serialize(&NaiveDateTime.to_iso8601(&1))
  end

  ###########
  # Objects #
  ###########

  object :session do
    field :jwt, non_null(:string)
  end

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
    field :position, non_null(:position), resolve: dataloader(DB)
    field :avatar, :string, resolve: fn user, _, _ ->
      {:ok, user.avatar && User.Avatar.url({user.avatar, user}, :thumb, signed: true)}
    end
  end

  object :vote do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :state, non_null(:string)
    field :deadline, :timestamp
    field :finish_date, :timestamp
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
    field :messages, list_of(:message), resolve: dataloader(DB)
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
    field :url, non_null(:string), resolve: fn attachment, _, _ ->
      {:ok, Attachment.File.url({attachment.file, attachment}, :original, signed: true)}
    end
  end

  ###########
  # Queries #
  ###########

  query do
    field :current_user, non_null(:user) do
      _root, _args, %{context: %{current_user: %User{} = user}} ->
        {:ok, user}

      _root, _args, _info ->
        {:error, "Unauthorized"}
    end

    field :list_positions, non_null(list_of(non_null(:position))) do
      resolve(fn _root, _args, _info ->
        {:ok, Position |> Repo.all()}
      end)
    end

    field :list_users, non_null(list_of(non_null(:user))) do
      resolve(fn _root, _args, _info ->
        {:ok, User |> Repo.all()}
      end)
    end

    field :list_votes, non_null(list_of(non_null(:vote))) do
      resolve(fn
        _root, _args, %{context: %{current_user: %User{}}} ->
          {:ok, Vote |> Repo.all()}

        _root, _args, _info ->
          {:error, "Unauthorized"}
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
    @desc "Login"
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(fn _root, %{email: email, password: password}, _info ->
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
      end)
    end

    @desc "Logout"
    field :logout, :user do
      arg(:id, non_null(:id))

      resolve(fn
        _root, _args, %{context: %{current_user: %User{} = user}} ->
          user |> Ecto.Changeset.cast(%{jwt: nil}, [:jwt]) |> Repo.update()

        _root, _args, _info ->
          {:error, "Please log in first!"}
      end)
    end

    @desc "Create position"
    field :create_position, :position do
      arg(:title, non_null(:string))
      arg(:weight, :float)

      resolve(fn
        _root, args, %{context: %{current_user: %User{}}} ->
          %Position{} |> Position.changeset(args) |> Repo.insert()

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create user"
    field :create_user, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:first_name, :string)
      arg(:middle_name, :string)
      arg(:last_name, :string)

      resolve(fn _root, args, _info ->
        %User{} |> User.registration_changeset(args) |> Repo.insert()
      end)
    end

    @desc "Update profile"
    field :update_profile, :user do
      arg(:email, :string)
      arg(:password, :string)
      arg(:first_name, :string)
      arg(:middle_name, :string)
      arg(:last_name, :string)
      arg(:avatar, :upload)

      resolve(fn
        _root, args, %{context: %{current_user: %User{} = user}} ->
          user |> User.profile_changeset(args) |> Repo.update()

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create vote"
    field :create_vote, :vote do
      arg(:title, non_null(:string))
      arg(:description, :string)
      arg(:deadline, :timestamp)
      arg(:attachments, list_of(:attachment_params))

      resolve(fn
        _root, args, %{context: %{current_user: %User{} = user}} ->
          Repo.transaction(fn ->
            result = %Vote{creator_id: user.id} |> Vote.changeset(args) |> Repo.insert()
            with {:ok, vote} <- result, do: vote |> Attachment.add_files(args.attachments)
          end)

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create participant"
    field :create_participant, :participant do
      arg(:vote_id, non_null(:integer))
      arg(:user_id, non_null(:integer))

      resolve(fn
        _root, args, %{context: %{current_user: %User{}}} ->
          %Participant{} |> Participant.changeset(args) |> Repo.insert()

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create topic"
    field :create_topic, :topic do
      arg(:vote_id, non_null(:integer))
      arg(:title, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(fn
        _root, args, %{context: %{current_user: %User{}}} ->
          Repo.transaction(fn ->
            with {:ok, topic} <- %Topic{} |> Topic.changeset(args) |> Repo.insert() do
              topic |> Attachment.add_files(args.attachments)
            end
          end)

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create message"
    field :create_message, :message do
      arg(:topic_id, non_null(:integer))
      arg(:text, non_null(:string))
      arg(:attachments, list_of(:attachment_params))

      resolve(fn
        _root, args, %{context: %{current_user: %User{} = user}} ->
          Repo.transaction(fn ->
            result = %Message{author_id: user.id} |> Message.changeset(args) |> Repo.insert()
            with {:ok, message} <- result, do: message |> Attachment.add_files(args.attachments)
          end)

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Create voice"
    field :create_voice, :voice do
      arg(:topic_id, :integer)
      arg(:decision, :integer)

      resolve(fn
        _root, args, %{context: %{current_user: %User{id: user_id}}} ->
          Voter.vote(args.topic_id, user_id, args.decision)

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end

    @desc "Cancel vote"
    field :cancel_vote, :vote do
      arg(:vote_id, :integer)

      resolve(fn
        _root, %{vote_id: id}, %{context: %{current_user: %User{}}} ->
          case Vote |> Repo.get(id) do
            %Vote{} = vote ->
              vote |> Ecto.Changeset.change(%{state: "cancelled"}) |> Repo.update()

            nil ->
              {:error, "Not found"}
          end

        _root, _args, _info ->
          {:error, "Unauthorized"}
      end)
    end
  end
end

defmodule VtbWeb.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Plug.Types)
  import Ecto.Query

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(DB, Dataloader.Ecto.new(Vtb.Repo, query: &scope/2))

    ctx |> Map.put(:loader, loader)
  end

  def scope(query, Vtb.Topic), do: query |> order_by([t], t.inserted_at)
  def scope(query, Vtb.Message), do: query |> order_by([m], m.inserted_at)
  def scope(query, _), do: query

  scalar :timestamp, name: "Timestamp" do
    parse(&NaiveDateTime.from_iso8601(&1))
    serialize(&NaiveDateTime.to_iso8601(&1))
  end

  import_types(VtbWeb.Schema.Session)
  import_types(VtbWeb.Schema.Position)
  import_types(VtbWeb.Schema.User)
  import_types(VtbWeb.Schema.Vote)
  import_types(VtbWeb.Schema.Topic)
  import_types(VtbWeb.Schema.Participant)
  import_types(VtbWeb.Schema.Message)
  import_types(VtbWeb.Schema.Voice)
  import_types(VtbWeb.Schema.Attachment)

  query do
    import_fields(:session_queries)
    import_fields(:position_queries)
    import_fields(:user_queries)
    import_fields(:vote_queries)
  end

  mutation do
    import_fields(:session_mutations)
    import_fields(:position_mutations)
    import_fields(:user_mutations)
    import_fields(:vote_mutations)
    import_fields(:topic_mutations)
    import_fields(:participant_mutations)
    import_fields(:message_mutations)
    import_fields(:voice_mutations)
  end
end

defmodule Vtb.Voter do
  alias Vtb.{Repo, Vote, Topic, Participant, Voice}
  import Ecto.Query

  def vote(topic_id, user_id, decision) do
    Repo.transaction(fn ->
      with {:ok, %Topic{vote: vote}} <- find_topic(topic_id),
          :ok <- vote.state == "ongoing" && :ok || {:error, "Vote is not active"},
          {:ok, _} <- find_participant(user_id, vote.id),
          {:ok, voice} <- create_voice(topic_id, user_id, decision),
          {:ok, _} <- if(needs_finish?(vote), do: finish(vote), else: {:ok, vote}),
          do: {:ok, voice}
    end)
  end

  defp find_topic(id) do
    case Topic |> Repo.get(id) do
      %Topic{} = topic -> {:ok, topic |> Repo.preload(:vote)}
      nil -> {:error, "Topic not found"}
    end
  end

  defp find_participant(user_id, vote_id) do
    case Participant |> Repo.get_by(user_id: user_id, vote_id: vote_id) do
      %Participant{} = participant -> {:ok, participant}
      nil -> {:error, "User does not participate in this vote"}
    end
  end

  defp create_voice(topic_id, user_id, decision) do
    %Voice{voter_id: user_id}
    |> Voice.changeset(%{topic_id: topic_id, decision: decision})
    |> Repo.insert()
  end

  defp needs_finish?(%Vote{id: vote_id}) do
    Participant
    |> join(:inner, [p], t in Topic, on: t.vote_id == p.vote_id)
    |> join(:left, [p, t], v in Voice, on: v.topic_id == t.id and v.user_id == p.user_id)
    |> where([p, t, v], p.vote_id == ^vote_id and is_nil(v.id))
    |> Repo.aggregate(:count, :id)
    |> Kernel.==(0)
  end

  defp finish(vote) do
    vote
    |> Ecto.Changeset.change(%{state: finish_state(vote), finished_at: NaiveDateTime.utc_now()})
    |> Repo.update()
  end

  defp finish_state(%Vote{id: vote_id}) do
    Voice
    |> join(:inner, [v], u in assoc(v, :voter))
    |> join(:inner, [v, u], p in assoc(u, :position))
    |> join(:inner, [v, u, p], t in assoc(v, :topic))
    |> where([v, u, p, t], t.vote_id == ^vote_id)
    |> group_by([v, u, p, t], t.id)
    |> select([v, u, p, t], %{total: fragment("SUM(? * ?)", v.decision, p.weight)})
    |> Repo.all()
    |> Enum.reduce_while("finished", fn
      %{total: 0}, _ -> {:halt, "undecided"}
      _, _ -> {:cont, "finished"}
    end)
  end
end

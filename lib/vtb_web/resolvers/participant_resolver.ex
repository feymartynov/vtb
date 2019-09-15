defmodule VtbWeb.ParticipantResolver do
  alias Vtb.{Repo, User, Participant, Mailer}

  def create(_root, args, %{context: %{current_user: %User{}}}) do
    with {:ok, participant} <- %Participant{} |> Participant.changeset(args) |> Repo.insert() do
      participant |> Repo.preload([:vote, :user]) |> notify_create()
      {:ok, participant}
    end
  end

  def create(_root, _args, _info) do
    {:error, "Unauthorized"}
  end

  defp notify_create(%Participant{vote: vote, user: user}) do
    bindings = [vote: vote, user: user]

    email =
      Bamboo.Email.new_email(
        to: {User.full_name(user), user.email},
        from: Application.get_env(:vtb, :from_email),
        subject: "Примите участие в голосовании \"#{vote.title}\"",
        html_body: EEx.eval_file("lib/vtb/email_templates/new_vote.html.eex", bindings)
      )

    Mailer.deliver_now(email)
  end
end

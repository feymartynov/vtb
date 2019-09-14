defmodule Vtb.Repo do
  use Ecto.Repo,
    otp_app: :vtb,
    adapter: Ecto.Adapters.Postgres
end

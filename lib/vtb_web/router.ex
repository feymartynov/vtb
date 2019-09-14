defmodule VtbWeb.Router do
  use VtbWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", VtbWeb do
    pipe_through :api
  end
end

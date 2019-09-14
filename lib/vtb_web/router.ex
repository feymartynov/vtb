defmodule VtbWeb.Router do
  use VtbWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug VtbWeb.Auth
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: VtbWeb.Schema
    forward "/", Absinthe.Plug, schema: VtbWeb.Schema
  end
end

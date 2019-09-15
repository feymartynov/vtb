defmodule VtbWeb.Router do
  use VtbWeb, :router

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
    plug VtbWeb.Auth
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: VtbWeb.Schema
    forward "/api", Absinthe.Plug, schema: VtbWeb.Schema
  end
end

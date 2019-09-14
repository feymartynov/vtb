defmodule VtbWeb.Router do
  use VtbWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug.GraphiQL,
      schema: VtbWeb.Schema,
      interface: :simple,
      context: %{pubsub: VtbWeb.Endpoint}
  end
end

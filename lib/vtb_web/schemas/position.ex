defmodule VtbWeb.Schema.Position do
  use Absinthe.Schema.Notation
  alias VtbWeb.PositionResolver

  @desc "Position"
  object :position do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :weight, non_null(:integer)
  end

  object :position_queries do
    @desc "List positions"
    field :list_positions, non_null(list_of(non_null(:position))) do
      resolve(&PositionResolver.list/3)
    end
  end

  object :position_mutations do
    @desc "Create position"
    field :create_position, :position do
      arg(:title, non_null(:string))
      arg(:weight, :float)

      resolve(&PositionResolver.create/3)
    end
  end
end

defmodule Engine.Game do
  @derive Jason.Encoder
  defstruct connections: [], objects: [], locations: [], enemies: [], npcs: []
end

defmodule Engine.GameEntity do
  @derive Jason.Encoder
  defstruct [:name, :state]
end

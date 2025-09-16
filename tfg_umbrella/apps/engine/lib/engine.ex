defmodule Engine do
  def create(%{"connection" => connection}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Connection, connection})
  end

  def create(%{"location" => location}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Location, location})
  end

  def create(%{"object" => object}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Object, object})
  end

  def create(%{"enemy" => enemy}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Enemy, enemy})
  end

  def create(%{"character" => character}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Character, character})
  end

  def create(%{"npc" => npc}, supervisor_name) do
    Engine.Utilities.advanced_to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Npc, npc})
  end

  def create(params, _) do
    {:error, "Bad creation. Got #{inspect(params)}"}
  end
end

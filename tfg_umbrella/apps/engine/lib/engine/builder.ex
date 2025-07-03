defmodule Engine.Builder do
  def create(%{"connection" => connection}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Connection, connection})
  end

  def create(%{"connection" => connection}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Connection, connection})
  end

  def create(%{"location" => location}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Location, location})
  end

  def create(%{"location" => location}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Location, location})
  end

  def create(%{"object" => object}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Object, object})
  end

  def create(%{"object" => object}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Object, object})
  end

  def create(%{"enemy" => enemy}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Enemy, enemy})
  end

  def create(%{"enemy" => enemy}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Enemy, enemy})
  end

  def create(%{"character" => character}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Character, character})
  end

  def create(%{"character" => character}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Character, character})
  end

  def create(%{"npc" => npc}, supervisor_name) when is_atom(supervisor_name) do
    DynamicSupervisor.start_child(supervisor_name, {Engine.Npc, npc})
  end

  def create(%{"npc" => npc}, supervisor_name) do
    String.to_atom(supervisor_name)
    |> DynamicSupervisor.start_child({Engine.Npc, npc})
  end

  def create(params, _) do
    {:error, "Bad creation. Got #{inspect(params)}"}
  end

  def init_game(name, supervisor) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)

    init_connections(saved_game.safe["connections"], supervisor)
    init_locations(saved_game.safe["locations"], supervisor)
    init_objects(saved_game.safe["objects"], supervisor)
    init_npcs(saved_game.safe["npcs"], supervisor)
    init_enemies(saved_game.safe["enemies"], supervisor)

    saved_user = Engine.User |> Engine.Repo.get(name)

    Engine.Builder.create(%{"character" => saved_user.character}, supervisor)
  end

  defp init_connections(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.Builder.create(%{"connection" => h}, s)
      init_connections(t, s)
    end
  end

  defp init_locations(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.Builder.create(%{"location" => h}, s)
      init_locations(t, s)
    end
  end

  defp init_objects(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.Builder.create(%{"object" => h}, s)
      init_objects(t, s)
    end
  end

  defp init_npcs(array, s) do
    if length(array) > 0 do
      [h | t] = array

      Engine.Builder.create(%{"npc" => h}, s)

      init_npcs(t, s)
    end
  end

  defp init_enemies(array, s) do
    if length(array) > 0 do
      [h | t] = array

      Engine.Builder.create(%{"enemy" => h}, s)

      init_enemies(t, s)
    end
  end
end

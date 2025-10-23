defmodule Game do
  require Logger

  def start() do
    saved_game = Engine.Safe |> Engine.Repo.get("current")

    init_connections(saved_game.safe["connections"], :main_supervisor)
    init_locations(saved_game.safe["locations"], :main_supervisor)
    init_objects(saved_game.safe["objects"], :main_supervisor)
    init_npcs(saved_game.safe["npcs"], :main_supervisor)
    init_enemies(saved_game.safe["enemies"])

    Logger.info("Game started")
  end

  def routes() do
    [
      {"goblin", :node1@enemies_node},
      {"tim", :node2@character_node},
      {"tom", :node2@character_node}
    ]
  end

  defp init_connections(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.create(%{"connection" => h}, s)
      init_connections(t, s)
    end
  end

  defp init_locations(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.create(%{"location" => h}, s)
      init_locations(t, s)
    end
  end

  defp init_objects(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.create(%{"object" => h}, s)
      init_objects(t, s)
    end
  end

  defp init_npcs(array, s) do
    if length(array) > 0 do
      [h | t] = array
      Engine.create(%{"npc" => h}, s)
      init_npcs(t, s)
    end
  end

  defp init_enemies(array) do
    if length(array) > 0 do
      [h | t] = array

      Game.RemoteEnemyManager.start_remote_enemy(
        h,
        Engine.Router.get_routed_name(
          Game.routes(),
          h["name"]
        )
      )

      init_enemies(t)
    end
  end
end

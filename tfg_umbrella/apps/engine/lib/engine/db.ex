defmodule Engine.Db do
  @moduledoc """
  Functions for database reading and writing.
  """
  def init() do
    Engine.Safe.changeset(%Engine.Safe{}, %{user_name: "initial", safe: %Engine.Game{}})
    |> Engine.Repo.insert()
  end

  def safe_game(user) do
    saved_game = Engine.Safe |> Engine.Repo.get(user)

    new_conns = get_connection_states(saved_game.safe["connections"], [])
    new_enemies = get_enemy_states(saved_game.safe["enemies"], [])
    new_objects = get_object_states(saved_game.safe["objects"], [])
    new_locations = get_location_states(saved_game.safe["locations"], [])
    new_npcs = get_npc_states(saved_game.safe["npcs"], [])

    Engine.Safe.changeset(
      saved_game,
      Map.from_struct(%Engine.Safe{
        user_name: user,
        safe: %Engine.Game{
          connections: new_conns,
          enemies: new_enemies,
          objects: new_objects,
          locations: new_locations,
          npcs: new_npcs
        }
      })
    )
    |> Engine.Repo.update()

    saved_user = Engine.User |> Engine.Repo.get(user)
    character_name = saved_user.character["name"]

    case :global.whereis_name(Engine.Utilities.advanced_to_atom(character_name)) do
      :undefined ->
        {:error, :not_started}

      pid ->
        new_character = Engine.Character.get_state(pid)

        Engine.User.changeset(
          saved_user,
          Map.from_struct(%Engine.User{
            username: saved_user.username,
            password: saved_user.password,
            character: %Engine.GameEntity{
              name: character_name,
              state: new_character
            }
          })
        )
        |> Engine.Repo.update()
    end
  end

  def get_character(name) do
    saved_user = Engine.User |> Engine.Repo.get(name)
    saved_user.character
  end

  def get_locations(name) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)
    saved_game.safe["locations"]
  end

  def get_connections(name) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)
    saved_game.safe["connections"]
  end

  def get_objects(name) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)
    saved_game.safe["objects"]
  end

  def get_npcs(name) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)
    saved_game.safe["npcs"]
  end

  def get_enemies(name) do
    saved_game = Engine.Safe |> Engine.Repo.get(name)
    saved_game.safe["enemies"]
  end

  def add_connection(conn) do
    new_conn = struct!(Engine.GameEntity, conn)

    save = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(
      save,
      Map.from_struct(%Engine.Safe{
        user_name: "initial",
        safe: %Engine.Game{
          connections: [new_conn | save.safe["connections"]],
          enemies: save.safe["enemies"],
          objects: save.safe["objects"],
          locations: save.safe["locations"],
          npcs: save.safe["npcs"]
        }
      })
    )
    |> Engine.Repo.update()
  end

  def add_enemy(enemy) do
    new_enemy = struct!(Engine.GameEntity, enemy)

    save = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(
      save,
      Map.from_struct(%Engine.Safe{
        user_name: "initial",
        safe: %Engine.Game{
          connections: save.safe["connections"],
          enemies: [new_enemy | save.safe["enemies"]],
          objects: save.safe["objects"],
          locations: save.safe["locations"],
          npcs: save.safe["npcs"]
        }
      })
    )
    |> Engine.Repo.update()
  end

  def add_object(obj) do
    new_obj = struct!(Engine.GameEntity, obj)

    save = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(
      save,
      Map.from_struct(%Engine.Safe{
        user_name: "initial",
        safe: %Engine.Game{
          connections: save.safe["connections"],
          enemies: save.safe["enemies"],
          objects: [new_obj | save.safe["objects"]],
          locations: save.safe["locations"],
          npcs: save.safe["npcs"]
        }
      })
    )
    |> Engine.Repo.update()
  end

  def add_location(location) do
    new_location = struct!(Engine.GameEntity, location)

    save = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(
      save,
      Map.from_struct(%Engine.Safe{
        user_name: "initial",
        safe: %Engine.Game{
          connections: save.safe["connections"],
          enemies: save.safe["enemies"],
          objects: save.safe["objects"],
          locations: [new_location | save.safe["locations"]],
          npcs: save.safe["npcs"]
        }
      })
    )
    |> Engine.Repo.update()
  end

  def add_npc(npc) do
    new_npc = struct!(Engine.GameEntity, npc)

    save = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(
      save,
      Map.from_struct(%Engine.Safe{
        user_name: "initial",
        safe: %Engine.Game{
          connections: save.safe["connections"],
          enemies: save.safe["enemies"],
          objects: save.safe["objects"],
          locations: save.safe["locations"],
          npcs: [new_npc | save.safe["npcs"]]
        }
      })
    )
    |> Engine.Repo.update()
  end

  defp get_connection_states(array, result) do
    if length(array) > 0 do
      [h | t] = array

      case :global.whereis_name(Engine.Utilities.advanced_to_atom(h["name"])) do
        :undefined ->
          {:error, :not_started}

        pid ->
          state = Engine.Connection.get_state(pid)

          result = [
            %Engine.GameEntity{name: h["name"], state: state} | result
          ]

          get_connection_states(t, result)
      end
    else
      result
    end
  end

  defp get_object_states(array, result) do
    if length(array) > 0 do
      [h | t] = array

      case :global.whereis_name(Engine.Utilities.advanced_to_atom(h["name"])) do
        :undefined ->
          {:error, :not_started}

        pid ->
          state = Engine.Object.get_state(pid)

          result = [
            %Engine.GameEntity{name: h["name"], state: state} | result
          ]

          get_object_states(t, result)
      end
    else
      result
    end
  end

  defp get_enemy_states(array, result) do
    if length(array) > 0 do
      [h | t] = array

      case :global.whereis_name(Engine.Utilities.advanced_to_atom(h["name"])) do
        :undefined ->
          {:error, :not_started}

        pid ->
          state = Engine.Enemy.get_state(pid)

          result = [
            %Engine.GameEntity{name: h["name"], state: state} | result
          ]

          get_enemy_states(t, result)
      end
    else
      result
    end
  end

  defp get_location_states(array, result) do
    if length(array) > 0 do
      [h | t] = array

      case :global.whereis_name(Engine.Utilities.advanced_to_atom(h["name"])) do
        :undefined ->
          {:error, :not_started}

        pid ->
          state = Engine.Location.get_state(pid)

          result = [
            %Engine.GameEntity{name: h["name"], state: state} | result
          ]

          get_location_states(t, result)
      end
    else
      result
    end
  end

  defp get_npc_states(array, result) do
    if length(array) > 0 do
      [h | t] = array

      case :global.whereis_name(Engine.Utilities.advanced_to_atom(h["name"])) do
        :undefined ->
          {:error, :not_started}

        pid ->
          state = Engine.Npc.get_state(pid)

          result = [
            %Engine.GameEntity{name: h["name"], state: state} | result
          ]

          get_npc_states(t, result)
      end
    else
      result
    end
  end
end

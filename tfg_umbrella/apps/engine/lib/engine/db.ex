defmodule Engine.Db do
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
    new_character = String.to_atom(character_name) |> Engine.Character.get_state()

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
      state = String.to_atom(h["name"]) |> Engine.Connection.get_state()

      result = [
        %Engine.GameEntity{name: h["name"], state: state} | result
      ]

      get_connection_states(t, result)
    else
      result
    end
  end

  defp get_object_states(array, result) do
    if length(array) > 0 do
      [h | t] = array
      state = String.to_atom(h["name"]) |> Engine.Object.get_state()

      result = [
        %Engine.GameEntity{name: h["name"], state: state} | result
      ]

      get_object_states(t, result)
    else
      result
    end
  end

  defp get_enemy_states(array, result) do
    if length(array) > 0 do
      [h | t] = array
      state = String.to_atom(h["name"]) |> Engine.Enemy.get_state()

      result = [
        %Engine.GameEntity{name: h["name"], state: state} | result
      ]

      get_enemy_states(t, result)
    else
      result
    end
  end

  defp get_location_states(array, result) do
    if length(array) > 0 do
      [h | t] = array
      state = String.to_atom(h["name"]) |> Engine.Location.get_state()

      result = [
        %Engine.GameEntity{name: h["name"], state: state} | result
      ]

      get_location_states(t, result)
    else
      result
    end
  end

  defp get_npc_states(array, result) do
    if length(array) > 0 do
      [h | t] = array
      state = String.to_atom(h["name"]) |> Engine.Npc.get_state()

      result = [
        %Engine.GameEntity{name: h["name"], state: state} | result
      ]

      get_npc_states(t, result)
    else
      result
    end
  end
end

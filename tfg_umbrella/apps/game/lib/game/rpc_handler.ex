defmodule Game.RpcHandler do
  def handle_rpc_request(%{"jsonrpc" => "2.0", "method" => "health", "id" => id}) do
    {:ok, %{"jsonrpc" => "2.0", "result" => "server working", "id" => id}}
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "start",
        "id" => id
      }) do
    Game.start()

    response_wrapper("game started", id)
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "save",
        "id" => id
      }) do
    Engine.Db.safe_game("prueba")

    response_wrapper("game saved", id)
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_character",
        "id" => id
      }) do
    loc_state = String.to_atom("prueba") |> Engine.Character.get_state()

    response_wrapper(
      %{
        level: loc_state.level,
        experience: loc_state.exp,
        inventory: loc_state.inventory,
        armor: %{
          head: loc_state.head,
          body: loc_state.body,
          arms: loc_state.arms,
          legs: loc_state.legs,
          feet: loc_state.feet
        },
        weapon: loc_state.weapon
      },
      id
    )
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_current_location",
        "id" => id
      }) do
    location = String.to_atom("prueba") |> Engine.Character.get_current_location()

    loc_state = String.to_atom(location) |> Engine.Location.get_state()

    response_wrapper(
      %{
        objects: loc_state.objects,
        connections: loc_state.connections,
        npc: loc_state.npc
      },
      id
    )
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "take_object",
        "params" => %{"object" => object_name},
        "id" => id
      }) do
    location = String.to_atom("prueba") |> Engine.Character.get_current_location()

    objects = String.to_atom(location) |> Engine.Location.get_objects()

    if Enum.member?(objects, object_name) do
      String.to_atom(location) |> Engine.Location.remove_object(object_name)
      String.to_atom("prueba") |> Engine.Character.add_to_inventory(object_name)
      response_wrapper("object #{object_name} picked", id)
    else
      response_wrapper("object #{object_name} is not in this location", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "equip_object",
        "params" => %{"object" => object_name},
        "id" => id
      }) do
    character_state = String.to_atom("prueba") |> Engine.Character.get_state()

    if(Enum.member?(character_state.inventory, object_name)) do
      object_type = String.to_atom(object_name) |> Engine.Object.get_type()
      String.to_atom("prueba") |> Engine.Character.equip_object(object_name, object_type)

      response_wrapper(
        "object #{object_name} has been equiped in the #{object_type} character slot",
        id
      )
    else
      response_wrapper("object not in the character inventory", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_connection",
        "params" => %{"connection" => conn_name},
        "id" => id
      }) do
    location = String.to_atom("prueba") |> Engine.Character.get_current_location()

    conns = String.to_atom(location) |> Engine.Location.get_connections()

    if Enum.member?(conns, conn_name) do
      next_location = String.to_atom(conn_name) |> Engine.Connection.get_next_location(location)
      response_wrapper("this connection leads to #{next_location}", id)
    else
      response_wrapper("connection #{conn_name} is not in this location", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "cross_connection",
        "params" => %{"connection" => conn_name},
        "id" => id
      }) do
    location = String.to_atom("prueba") |> Engine.Character.get_current_location()

    next_location = String.to_atom(conn_name) |> Engine.Connection.get_next_location(location)

    if next_location !== "error" do
      String.to_atom("prueba") |> Engine.Character.change_location(next_location)
      enemy = String.to_atom(next_location) |> Engine.Location.get_enemy()

      if enemy !== nil do
        String.to_atom("prueba") |> Engine.Character.change_combat_status(true)

        response_wrapper(
          "you have traveled to #{next_location}. There is an enemy, you have entered combat mode. Enemy: #{enemy}",
          id
        )
      else
        response_wrapper("you have traveled to #{next_location}", id)
      end
    else
      response_wrapper("you could not take the connection from where you are", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "attack",
        "params" => %{"enemy" => enemy_name},
        "id" => id
      }) do
    location = String.to_atom("prueba") |> Engine.Character.get_current_location()
    status = String.to_atom("prueba") |> Engine.Character.is_in_combat?()

    if status do
      enemy = String.to_atom(location) |> Engine.Location.get_enemy()

      if enemy !== enemy_name do
        response_wrapper("you can not attack this enemy", id)
      else
        ch_level = String.to_atom("prueba") |> Engine.Character.get_level()
        en_level = String.to_atom(enemy_name) |> Engine.Enemy.get_level()

        case Engine.Dice.check_combat_turn(ch_level, en_level) do
          :character ->
            dmg = String.to_atom("prueba") |> Engine.Character.get_attack_damage()
            String.to_atom(enemy_name) |> Engine.Enemy.hit(dmg)

            if String.to_atom(enemy_name) |> Engine.Enemy.is_alive?() do
              e_dmg = String.to_atom(enemy_name) |> Engine.Enemy.get_attack_damage()
              String.to_atom("prueba") |> Engine.Character.hit(e_dmg)

              if String.to_atom("prueba") |> Engine.Character.is_alive?() do
                c_health = String.to_atom("prueba") |> Engine.Character.get_health()
                e_health = String.to_atom(enemy_name) |> Engine.Enemy.get_health()

                response_wrapper(
                  "the enemy has done #{e_dmg} damage to you. Character health remaining: #{c_health}. Enemy health remaining: #{e_health}",
                  id
                )
              else
                response_wrapper("you have died", id)
              end
            else
              String.to_atom("prueba") |> Engine.Character.change_combat_status(false)
              response_wrapper("you killed the enemy", id)
            end

          :enemy ->
            dmg = String.to_atom(enemy_name) |> Engine.Enemy.get_attack_damage()
            String.to_atom("prueba") |> Engine.Character.hit(dmg)

            if String.to_atom("prueba") |> Engine.Character.is_alive?() do
              c_dmg = String.to_atom("prueba") |> Engine.Character.get_attack_damage()
              String.to_atom(enemy_name) |> Engine.Enemy.hit(c_dmg)

              if String.to_atom(enemy_name) |> Engine.Enemy.is_alive?() do
                c_health = String.to_atom("prueba") |> Engine.Character.get_health()
                e_health = String.to_atom(enemy_name) |> Engine.Enemy.get_health()

                response_wrapper(
                  "the enemy has done #{dmg} damage to you. Character health remaining: #{c_health}. Enemy health remaining: #{e_health}",
                  id
                )
              else
                String.to_atom("prueba") |> Engine.Character.change_combat_status(false)
                response_wrapper("you killed the enemy", id)
              end
            else
              response_wrapper("you have died", id)
            end
        end
      end
    else
      response_wrapper("you are not in a combat", id)
    end
  end

  def handle_rpc_request(%{"jsonrpc" => "2.0", "method" => method, "id" => id}) do
    error_wrapper(-32601, "Method not found: #{method}", id)
  end

  def handle_rpc_request(_) do
    error_wrapper(-32600, "Invalid request", nil)
  end

  defp response_wrapper(result, id) do
    {:ok, %{"jsonrpc" => "2.0", "result" => result, "id" => id}}
  end

  defp error_wrapper(code, reason, id) do
    {:error,
     %{
       "jsonrpc" => "2.0",
       "error" => %{"code" => code, "message" => reason},
       "id" => id
     }}
  end
end

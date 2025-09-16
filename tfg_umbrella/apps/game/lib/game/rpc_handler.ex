defmodule Game.RpcHandler do
  def handle_rpc_request(%{"jsonrpc" => "2.0", "method" => "health", "id" => id}) do
    {:ok, %{"jsonrpc" => "2.0", "result" => "server working", "id" => id}}
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "start",
        "id" => id
      }) do
    try do
      Game.start()

      response_wrapper("game started", id)
    rescue
      e -> error_wrapper(-32603, "#{inspect(e)}", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "save",
        "id" => id
      }) do
    try do
      Engine.Db.safe_game("prueba")

      response_wrapper("game saved", id)
    rescue
      e -> error_wrapper(-32603, "#{inspect(e)}", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_character",
        "id" => id
      }) do
    try do
      loc_state = Game.RemoteCharacterManager.get_state(:prueba)

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
    rescue
      e -> error_wrapper(-32603, "#{inspect(e)}", id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_current_location",
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)

      loc_state =
        Engine.Location.get_state({:global, Engine.Utilities.advanced_to_atom(location)})

      response_wrapper(
        %{
          objects: loc_state.objects,
          connections: loc_state.connections,
          npc: loc_state.npc
        },
        id
      )
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "take_object",
        "params" => %{"object" => object_name},
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)

      objects =
        Engine.Location.get_objects({:global, Engine.Utilities.advanced_to_atom(location)})

      if Enum.member?(objects, object_name) do
        Engine.Location.remove_object(
          {:global, Engine.Utilities.advanced_to_atom(location)},
          object_name
        )

        Game.RemoteCharacterManager.add_to_inventory(:prueba, object_name)
        response_wrapper("object #{object_name} picked", id)
      else
        response_wrapper("object #{object_name} is not in this location", id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "equip_object",
        "params" => %{"object" => object_name},
        "id" => id
      }) do
    try do
      character_state = Game.RemoteCharacterManager.get_state(:prueba)

      if(Enum.member?(character_state.inventory, object_name)) do
        object_type =
          Engine.Object.get_type({:global, Engine.Utilities.advanced_to_atom(object_name)})

        Game.RemoteCharacterManager.equip_object(:prueba, object_name, object_type)

        response_wrapper(
          "object #{object_name} has been equiped in the #{object_type} character slot",
          id
        )
      else
        response_wrapper("object not in the character inventory", id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "inspect_connection",
        "params" => %{"connection" => conn_name},
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)

      conns =
        Engine.Location.get_connections({:global, Engine.Utilities.advanced_to_atom(location)})

      if Enum.member?(conns, conn_name) do
        next_location =
          Engine.Connection.get_next_location(
            {:global, Engine.Utilities.advanced_to_atom(conn_name)},
            location
          )

        response_wrapper("this connection leads to #{next_location}", id)
      else
        response_wrapper("connection #{conn_name} is not in this location", id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "cross_connection",
        "params" => %{"connection" => conn_name},
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)

      object =
        Engine.Connection.get_object({:global, Engine.Utilities.advanced_to_atom(conn_name)})

      if object != nil do
        inventory = Game.RemoteCharacterManager.get_inventory(:prueba)

        if Enum.member?(inventory, object) do
          move_character(conn_name, location, id)
        else
          response_wrapper(
            "you do not have the necessary object for crossing to the next location",
            id
          )
        end
      else
        move_character(conn_name, location, id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "area_attack",
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)
      status = Game.RemoteCharacterManager.is_in_combat?(:prueba)
      dmg = Game.RemoteCharacterManager.get_attack_damage(:prueba)

      if status do
        enemies =
          Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(location)})

        Enum.each(enemies, fn enemy ->
          Engine.Utilities.advanced_to_atom(enemy) |> Game.RemoteEnemyManager.hit(dmg)
        end)

        results =
          Enum.reduce(enemies, [], fn enemy, list ->
            [
              Engine.Utilities.advanced_to_atom(enemy) |> Game.RemoteEnemyManager.is_alive?()
              | list
            ]
          end)

        some_alive? = Enum.member?(results, true)

        if some_alive? do
          Enum.each(enemies, fn enemy ->
            if Engine.Utilities.advanced_to_atom(enemy) |> Game.RemoteEnemyManager.is_alive?() do
              e_dmg =
                Engine.Utilities.advanced_to_atom(enemy)
                |> Game.RemoteEnemyManager.get_attack_damage()

              Game.RemoteCharacterManager.hit(:prueba, e_dmg)
            end
          end)

          if Game.RemoteCharacterManager.is_alive?(:prueba) do
            response_wrapper("some enemies survived the attack", id)
          else
            response_wrapper("you have died", id)
          end
        else
          Game.RemoteCharacterManager.change_combat_status(:prueba, false)
          response_wrapper("you killed the enemies", id)
        end
      else
        response_wrapper("you are not in a combat", id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "attack",
        "params" => %{"enemy" => enemy_name},
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)
      status = Game.RemoteCharacterManager.is_in_combat?(:prueba)

      if status do
        enemies =
          Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(location)})

        if !Enum.member?(enemies, enemy_name) do
          response_wrapper("you can not attack this enemy", id)
        else
          ch_level = Game.RemoteCharacterManager.get_level(:prueba)

          en_level =
            Engine.Utilities.advanced_to_atom(enemy_name) |> Game.RemoteEnemyManager.get_level()

          case Engine.Dice.check_combat_turn(ch_level, en_level) do
            :character ->
              dmg = Game.RemoteCharacterManager.get_attack_damage(:prueba)
              Engine.Utilities.advanced_to_atom(enemy_name) |> Game.RemoteEnemyManager.hit(dmg)

              total_damage = get_total_damage(enemies)

              if total_damage !== 0 do
                Game.RemoteCharacterManager.hit(:prueba, total_damage)

                if Game.RemoteCharacterManager.is_alive?(:prueba) do
                  c_health = Game.RemoteCharacterManager.get_health(:prueba)

                  e_health =
                    Engine.Utilities.advanced_to_atom(enemy_name)
                    |> Game.RemoteEnemyManager.get_health()

                  response_wrapper(
                    "the enemy has done #{total_damage} damage to you. Character health remaining: #{c_health}. Enemy health remaining: #{e_health}",
                    id
                  )
                else
                  response_wrapper("you have died", id)
                end
              else
                Game.RemoteCharacterManager.change_combat_status(:prueba, false)
                response_wrapper("you cleared the room", id)
              end

            :enemy ->
              total_damage = get_total_damage(enemies)
              Game.RemoteCharacterManager.hit(:prueba, total_damage)

              if Game.RemoteCharacterManager.is_alive?(:prueba) do
                c_dmg = Game.RemoteCharacterManager.get_attack_damage(:prueba)

                Engine.Utilities.advanced_to_atom(enemy_name)
                |> Game.RemoteEnemyManager.hit(c_dmg)

                if Engine.Utilities.advanced_to_atom(enemy_name)
                   |> Game.RemoteEnemyManager.is_alive?() do
                  c_health = Game.RemoteCharacterManager.get_health(:prueba)

                  e_health =
                    Engine.Utilities.advanced_to_atom(enemy_name)
                    |> Game.RemoteEnemyManager.get_health()

                  response_wrapper(
                    "the enemy has done #{total_damage} damage to you. Character health remaining: #{c_health}. Enemy health remaining: #{e_health}",
                    id
                  )
                else
                  Game.RemoteCharacterManager.change_combat_status(:prueba, false)
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
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
    end
  end

  def handle_rpc_request(%{
        "jsonrpc" => "2.0",
        "method" => "interact",
        "params" => %{"npc" => npc_name},
        "id" => id
      }) do
    try do
      location = Game.RemoteCharacterManager.get_current_location(:prueba)

      npc = Engine.Location.get_npc({:global, Engine.Utilities.advanced_to_atom(location)})

      if npc !== nil && npc === npc_name do
        can_interact = Engine.Npc.interact({:global, Engine.Utilities.advanced_to_atom(npc)})

        if can_interact do
          interaction =
            Engine.Npc.get_interaction({:global, Engine.Utilities.advanced_to_atom(npc)})

          Game.RemoteCharacterManager.add_to_inventory(:prueba, interaction)

          response_wrapper(
            "#{npc_name} has given you #{interaction}. You saved it in the inventory",
            id
          )
        else
          response_wrapper("#{npc_name} ignores you", id)
        end
      else
        response_wrapper("#{npc_name} is not in this location", id)
      end
    rescue
      e in RuntimeError -> error_wrapper(-32603, e.message, id)
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

  defp move_character(conn_name, location, id) do
    next_location =
      Engine.Connection.get_next_location(
        {:global, Engine.Utilities.advanced_to_atom(conn_name)},
        location
      )

    if next_location !== "error" do
      Game.RemoteCharacterManager.change_location(:prueba, next_location)

      enemy =
        Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(next_location)})

      if enemy !== [] do
        Game.RemoteCharacterManager.change_combat_status(:prueba, true)

        response_wrapper(
          "you have traveled to #{next_location}. There is an enemy, you have entered combat mode. Enemy: #{Enum.join(enemy, ", ")}",
          id
        )
      else
        response_wrapper("you have traveled to #{next_location}", id)
      end
    else
      response_wrapper("you could not take the connection from where you are", id)
    end
  end

  defp get_total_damage(enemies) do
    Enum.reduce(enemies, 0, fn enemy, total_damage ->
      if Engine.Utilities.advanced_to_atom(enemy) |> Game.RemoteEnemyManager.is_alive?() do
        dmg =
          Engine.Utilities.advanced_to_atom(enemy) |> Game.RemoteEnemyManager.get_attack_damage()

        total_damage + dmg
      end
    end)
  end
end

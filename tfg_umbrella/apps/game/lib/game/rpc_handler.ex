defmodule Game.RpcHandler do
  use ThousandIsland.Handler
  require Logger

  @method_definition """
  Information is described as: method -> description (params)
  save -> saves the game for username (username: string)
  login -> logs in and starts users's character if login is correct (username: string, password: string)
  inspect_character -> returns character's status (character_name: string)
  inspect_current_location -> returns charcter's location information (character_name: string)
  equip_object -> equips the selected object from the character's inventory (character_name: string, object: string)
  inspect_connection -> returns next location if selected connection is used based on character's position in the game (character_name: string, connection: string)
  take_object -> selected character picks an object from the location it is in (character_name: string, object: string)
  cross_connection -> character travels to the next location via the connection (character_name: string, connection: string)
  attack -> character attacks and enemy in its current location (character_name: string, enemay: string)
  interact -> character interacts with an NPC in its current location (character_name: string, npc: string)
  """

  @impl ThousandIsland.Handler
  def handle_data(
        data,
        socket,
        state
      )
      when is_binary(data) do
    case Jason.decode(data) do
      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "info",
         "id" => id
       }} ->
        response_wrapper(socket, @method_definition, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "save",
         "params" => %{"username" => username},
         "id" => id
       }} ->
        Engine.Db.safe_game("current", username)
        response_wrapper(socket, "game saved", id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "login",
         "params" => %{"username" => username, "password" => password},
         "id" => id
       }} ->
        login(socket, username, password, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "inspect_character",
         "params" => %{"character_name" => character_name},
         "id" => id
       }} ->
        inspect_character(socket, character_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "inspect_current_location",
         "params" => %{"character_name" => character_name},
         "id" => id
       }} ->
        inspect_current_location(socket, character_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "equip_object",
         "params" => %{"object" => object_name, "character_name" => character_name},
         "id" => id
       }} ->
        equip_object(socket, character_name, object_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "inspect_connection",
         "params" => %{"connection" => conn_name, "character_name" => character_name},
         "id" => id
       }} ->
        inspect_location(socket, character_name, conn_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "take_object",
         "params" => %{"object" => object_name, "character_name" => character_name},
         "id" => id
       }} ->
        take_object(socket, character_name, object_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "cross_connection",
         "params" => %{"connection" => conn_name, "character_name" => character_name},
         "id" => id
       }} ->
        cross_connection(socket, character_name, conn_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "attack",
         "params" => %{"enemy" => enemy_name, "character_name" => character_name},
         "id" => id
       }} ->
        attack(socket, character_name, enemy_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => "interact",
         "params" => %{"npc" => npc_name, "character_name" => character_name},
         "id" => id
       }} ->
        interact(socket, character_name, npc_name, id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => method,
         "id" => id
       }} ->
        Logger.warning("unknown method: #{inspect(method)}")
        error_wrapper(socket, -32601, "unknown method", id)
        {:continue, state}

      {:ok,
       %{
         "jsonrpc" => "2.0",
         "method" => method,
         "params" => _,
         "id" => id
       }} ->
        Logger.warning("unknown method: #{inspect(method)}")
        error_wrapper(socket, -32601, "unknown method", id)
        {:continue, state}

      {:ok, msg} ->
        Logger.warning("unknown json message: #{inspect(msg)}")
        error_wrapper(socket, -32600, "unknown json message", nil)
        {:continue, state}

      {:error, err} ->
        Logger.error("decodification error: #{inspect(err)}")
        error_wrapper(socket, -32600, "internal server error", nil)
        {:continue, state}
    end
  end

  defp login(socket, username, password, id) do
    case Engine.Authentication.login(username, password) do
      :ok ->
        character = Engine.Db.get_character(username)

        res =
          Game.RemoteCharacterManager.start_remote_character(
            character,
            Engine.Router.get_routed_name(Game.routes(), character["name"])
          )

        Logger.info("Remote result: #{inspect(res)}")

        response_wrapper(socket, "you can now play as #{character["name"]}", id)

      :error ->
        error_wrapper(socket, -32001, "wrong username or password", id)
    end
  end

  defp inspect_character(socket, character_name, id) do
    loc_state =
      Engine.Utilities.advanced_to_atom(character_name) |> Game.RemoteCharacterManager.get_state()

    response_wrapper(
      socket,
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

  defp inspect_current_location(socket, character_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    enemies = Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(location)})

    loc_state =
      Engine.Location.get_state({:global, Engine.Utilities.advanced_to_atom(location)})

    response_wrapper(
      socket,
      %{
        objects: loc_state.objects,
        connections: loc_state.connections,
        npc: loc_state.npc,
        enemies: enemies
      },
      id
    )
  end

  defp take_object(socket, character_name, object_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    objects =
      Engine.Location.get_objects({:global, Engine.Utilities.advanced_to_atom(location)})

    if Enum.member?(objects, object_name) do
      Engine.Location.remove_object(
        {:global, Engine.Utilities.advanced_to_atom(location)},
        object_name
      )

      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.add_to_inventory(object_name)

      response_wrapper(socket, "object #{object_name} picked", id)
    else
      response_wrapper(socket, "object #{object_name} is not in this location", id)
    end
  end

  defp equip_object(socket, character_name, object_name, id) do
    character_state =
      Engine.Utilities.advanced_to_atom(character_name) |> Game.RemoteCharacterManager.get_state()

    if(Enum.member?(character_state.inventory, object_name)) do
      object_type =
        Engine.Object.get_type({:global, Engine.Utilities.advanced_to_atom(object_name)})

      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.equip_object(object_name, object_type)

      response_wrapper(
        socket,
        "object #{object_name} has been equiped in the #{object_type} character slot",
        id
      )
    else
      response_wrapper(socket, "object not in the character inventory", id)
    end
  end

  defp inspect_location(socket, character_name, conn_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    conns =
      Engine.Location.get_connections({:global, Engine.Utilities.advanced_to_atom(location)})

    if Enum.member?(conns, conn_name) do
      next_location =
        Engine.Connection.get_next_location(
          {:global, Engine.Utilities.advanced_to_atom(conn_name)},
          location
        )

      response_wrapper(socket, "this connection leads to #{next_location}", id)
    else
      response_wrapper(socket, "connection #{conn_name} is not in this location", id)
    end
  end

  defp cross_connection(socket, character_name, conn_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    object =
      Engine.Connection.get_object({:global, Engine.Utilities.advanced_to_atom(conn_name)})

    if object != nil do
      inventory =
        Engine.Utilities.advanced_to_atom(character_name)
        |> Game.RemoteCharacterManager.get_inventory()

      if Enum.member?(inventory, object) do
        move_character(socket, character_name, conn_name, location, id)
      else
        response_wrapper(
          socket,
          "you do not have the necessary object for crossing to the next location",
          id
        )
      end
    else
      move_character(socket, character_name, conn_name, location, id)
    end
  end

  defp attack(socket, character_name, enemy_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    status =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.is_in_combat?()

    if status do
      enemies =
        Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(location)})

      if !Enum.member?(enemies, enemy_name) do
        response_wrapper(socket, "you can not attack this enemy", id)
      else
        ch_level =
          Engine.Utilities.advanced_to_atom(character_name)
          |> Game.RemoteCharacterManager.get_level()

        en_level =
          Engine.Utilities.advanced_to_atom(enemy_name) |> Game.RemoteEnemyManager.get_level()

        case Engine.Dice.check_combat_turn(ch_level, en_level) do
          :character ->
            dmg =
              Engine.Utilities.advanced_to_atom(character_name)
              |> Game.RemoteCharacterManager.get_attack_damage()

            Engine.Utilities.advanced_to_atom(enemy_name) |> Game.RemoteEnemyManager.hit(dmg)

            total_damage = get_total_damage(enemies)

            if total_damage !== 0 do
              left_health =
                Engine.Utilities.advanced_to_atom(character_name)
                |> Game.RemoteCharacterManager.hit(total_damage)

              if left_health > 0 do
                e_health =
                  Engine.Utilities.advanced_to_atom(enemy_name)
                  |> Game.RemoteEnemyManager.get_health()

                response_wrapper(
                  socket,
                  "the enemy has done #{total_damage} damage to you. Character health remaining: #{left_health}. Enemy health remaining: #{e_health}",
                  id
                )
              else
                response_wrapper(socket, "you have died", id)
              end
            else
              Engine.Utilities.advanced_to_atom(character_name)
              |> Game.RemoteCharacterManager.change_combat_status(false)

              response_wrapper(socket, "you cleared the room", id)
            end

          :enemy ->
            total_damage = get_total_damage(enemies)

            left_health =
              Engine.Utilities.advanced_to_atom(character_name)
              |> Game.RemoteCharacterManager.hit(total_damage)

            if left_health > 0 do
              c_dmg =
                Engine.Utilities.advanced_to_atom(character_name)
                |> Game.RemoteCharacterManager.get_attack_damage()

              left_enemy_health =
                Engine.Utilities.advanced_to_atom(enemy_name)
                |> Game.RemoteEnemyManager.hit(c_dmg)

              if left_enemy_health > 0 do
                response_wrapper(
                  socket,
                  "the enemy has done #{total_damage} damage to you. Character health remaining: #{left_health}. Enemy health remaining: #{left_enemy_health}",
                  id
                )
              else
                Engine.Utilities.advanced_to_atom(character_name)
                |> Game.RemoteCharacterManager.change_combat_status(false)

                response_wrapper(socket, "you killed the enemy", id)
              end
            else
              response_wrapper(socket, "you have died", id)
            end
        end
      end
    else
      response_wrapper(socket, "you are not in a combat", id)
    end
  end

  defp interact(socket, character_name, npc_name, id) do
    location =
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.get_current_location()

    npc = Engine.Location.get_npc({:global, Engine.Utilities.advanced_to_atom(location)})

    if npc !== nil && npc === npc_name do
      can_interact = Engine.Npc.interact({:global, Engine.Utilities.advanced_to_atom(npc)})

      if can_interact do
        interaction =
          Engine.Npc.get_interaction({:global, Engine.Utilities.advanced_to_atom(npc)})

        Engine.Utilities.advanced_to_atom(character_name)
        |> Game.RemoteCharacterManager.add_to_inventory(interaction)

        response_wrapper(
          socket,
          "#{npc_name} has given you #{interaction}. You saved it in the inventory",
          id
        )
      else
        response_wrapper(socket, "#{npc_name} ignores you", id)
      end
    else
      response_wrapper(socket, "#{npc_name} is not in this location", id)
    end
  end

  defp move_character(socket, character_name, conn_name, location, id) do
    next_location =
      Engine.Connection.get_next_location(
        {:global, Engine.Utilities.advanced_to_atom(conn_name)},
        location
      )

    if next_location !== "error" do
      Engine.Utilities.advanced_to_atom(character_name)
      |> Game.RemoteCharacterManager.change_location(next_location)

      enemy =
        Engine.Location.get_enemy({:global, Engine.Utilities.advanced_to_atom(next_location)})

      if enemy !== [] do
        Engine.Utilities.advanced_to_atom(character_name)
        |> Game.RemoteCharacterManager.change_combat_status(true)

        response_wrapper(
          socket,
          "you have traveled to #{next_location}. There is an enemy, you have entered combat mode. Enemy: #{Enum.join(enemy, ", ")}",
          id
        )
      else
        response_wrapper(socket, "you have traveled to #{next_location}", id)
      end
    else
      response_wrapper(socket, "you could not take the connection from where you are", id)
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

  defp response_wrapper(socket, result, id) do
    ThousandIsland.Socket.send(
      socket,
      Jason.encode!(%{"jsonrpc" => "2.0", "result" => result, "id" => id}) <> "\n"
    )
  end

  defp error_wrapper(socket, code, reason, id) do
    ThousandIsland.Socket.send(
      socket,
      Jason.encode!(%{
        "jsonrpc" => "2.0",
        "error" => %{"code" => code, "message" => reason},
        "id" => id
      }) <> "\n"
    )
  end
end

defmodule Game.RemoteCharacterManager do
  @timeout 5000

  def start_remote_character(character, node) do
    Node.connect(node)

    if node in Node.list() do
      id = Engine.Utilities.advanced_to_atom(character["name"])

      case :rpc.call(node, :global, :whereis_name, [id]) do
        :undefined ->
          spec = %{
            id: id,
            start: {Engine.Character, :start_link, [character]},
            restart: :transient,
            shutdown: 5000,
            type: :worker
          }

          case :rpc.call(
                 node,
                 DynamicSupervisor,
                 :start_child,
                 [Engine.Supervisor, spec],
                 @timeout
               ) do
            {:ok, pid} -> {:ok, pid}
            {:error, reason} -> {:error, reason}
          end

        pid when is_pid(pid) ->
          {:ok, pid}
      end
    else
      {:error, :node_unreachable}
    end
  end

  def get_state(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_state(pid)
    end
  end

  def get_current_location(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_current_location(pid)
    end
  end

  def add_to_inventory(id, object_name) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.add_to_inventory(pid, object_name)
    end
  end

  def equip_object(id, object_name, object_type) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.equip_object(pid, object_name, object_type)
    end
  end

  def get_inventory(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_inventory(pid)
    end
  end

  def is_in_combat?(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.is_in_combat?(pid)
    end
  end

  def get_attack_damage(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_attack_damage(pid)
    end
  end

  def hit(id, dmg) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.hit(pid, dmg)
    end
  end

  def is_alive?(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.is_alive?(pid)
    end
  end

  def change_combat_status(id, status) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.change_combat_status(pid, status)
    end
  end

  def get_level(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_level(pid)
    end
  end

  def get_health(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.get_health(pid)
    end
  end

  def change_location(id, location) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Character.change_location(pid, location)
    end
  end
end

defmodule Game.RemoteEnemyManager do
  @timeout 5000

  def start_remote_enemy(enemy, node) do
    Node.connect(node)

    if node in Node.list() do
      id = Engine.Utilities.advanced_to_atom(enemy["name"])

      case :rpc.call(node, :global, :whereis_name, [id]) do
        :undefined ->
          spec = %{
            id: id,
            start: {Engine.Enemy, :start_link, [enemy]},
            restart: :transient,
            shutdown: 5000,
            type: :worker
          }

          case :rpc.call(
                 node,
                 DynamicSupervisor,
                 :start_child,
                 [Engine.Supervisor, spec],
                 @timeout
               ) do
            {:ok, pid} -> {:ok, pid}
            {:error, reason} -> {:error, reason}
          end

        pid when is_pid(pid) ->
          {:ok, pid}
      end
    else
      {:error, :node_unreachable}
    end
  end

  def hit(id, dmg) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Enemy.hit(pid, dmg)
    end
  end

  def is_alive?(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Enemy.is_alive?(pid)
    end
  end

  def get_attack_damage(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Enemy.get_attack_damage(pid)
    end
  end

  def get_level(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Enemy.get_level(pid)
    end
  end

  def get_health(id) do
    case :global.whereis_name(id) do
      :undefined -> {:error, :not_started}
      pid -> Engine.Enemy.get_health(pid)
    end
  end
end

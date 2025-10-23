defmodule Engine.Character do
  use GenServer

  @moduledoc """
  Definition of an engine character.
  """

  @derive Jason.Encoder
  defstruct level: 1,
            charisma: 1,
            wisdom: 1,
            intelligence: 1,
            constitution: 1,
            dexterity: 1,
            strength: 1,
            health: 100,
            exp: 0,
            inventory: [],
            head: nil,
            body: nil,
            arms: nil,
            legs: nil,
            feet: nil,
            weapon: nil,
            missions: [],
            current_location: "",
            in_combat: false

  def start_link(%Engine.GameEntity{name: name, state: state}) do
    GenServer.start_link(__MODULE__, state,
      name: {:global, Engine.Utilities.advanced_to_atom(name)}
    )
  end

  def start_link(init_config) do
    name =
      cond do
        is_map(init_config) and not is_struct(init_config) ->
          Map.get(init_config, "name") || Map.get(init_config, :name)

        match?(%__MODULE__{}, init_config) ->
          init_config.name

        true ->
          nil
      end

    init_arg =
      cond do
        is_map(init_config) and not is_struct(init_config) ->
          Map.get(init_config, "state") || Map.get(init_config, :state)

        match?(%__MODULE__{}, init_config) ->
          init_config.state

        true ->
          nil
      end

    GenServer.start_link(__MODULE__, init_arg,
      name: {:global, Engine.Utilities.advanced_to_atom(name)}
    )
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def get_stats(name) do
    GenServer.call(name, :get_stats)
  end

  def get_health(name) do
    GenServer.call(name, :get_health)
  end

  def get_exp(name) do
    GenServer.call(name, :get_exp)
  end

  def get_level(name) do
    GenServer.call(name, :get_level)
  end

  def get_current_location(name) do
    GenServer.call(name, :get_current_location)
  end

  def is_alive?(name) do
    GenServer.call(name, :is_alive?)
  end

  def is_in_combat?(name) do
    GenServer.call(name, :is_in_combat?)
  end

  def get_attack_damage(name) do
    GenServer.call(name, :get_attack_damage)
  end

  def get_inventory(name) do
    GenServer.call(name, :get_inventory)
  end

  def hit(name, hit_points) do
    GenServer.call(name, {:hit, hit_points})
  end

  def add_exp(name, exp) do
    GenServer.cast(name, {:add_exp, exp})
  end

  def add_to_inventory(name, element) do
    GenServer.cast(name, {:add_to_inventory, element})
  end

  def change_location(name, location) do
    GenServer.cast(name, {:change_location, location})
  end

  def equip_object(name, object, type) do
    GenServer.cast(name, {:equip_object, {object, type}})
  end

  def change_combat_status(name, status) do
    GenServer.cast(name, {:change_combat_status, status})
  end

  @impl true
  def init(%Engine.Character{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Character{
      level: initial_state["level"],
      charisma: initial_state["charisma"],
      wisdom: initial_state["wisdom"],
      intelligence: initial_state["intelligence"],
      constitution: initial_state["constitution"],
      dexterity: initial_state["dexterity"],
      strength: initial_state["strength"],
      health: initial_state["health"],
      exp: initial_state["exp"],
      inventory: initial_state["inventory"],
      head: initial_state["head"],
      body: initial_state["body"],
      arms: initial_state["arms"],
      legs: initial_state["legs"],
      feet: initial_state["feet"],
      weapon: initial_state["weapon"],
      missions: initial_state["missions"],
      current_location: initial_state["current_location"],
      in_combat: initial_state["in_combat"]
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_stats, _from, state) do
    {:reply,
     %{
       charisma: state.charisma,
       wisdom: state.wisdom,
       itelligence: state.intelligence,
       constitution: state.constitution,
       dexterity: state.dexterity,
       strength: state.strength
     }, state}
  end

  @impl true
  def handle_call(:get_health, _from, state) do
    {:reply, state.health, state}
  end

  @impl true
  def handle_call(:get_exp, _from, state) do
    {:reply, state.exp, state}
  end

  @impl true
  def handle_call(:get_level, _from, state) do
    {:reply, state.level, state}
  end

  @impl true
  def handle_call(:get_current_location, _from, state) do
    {:reply, state.current_location, state}
  end

  @impl true
  def handle_call(:is_alive?, _from, state) do
    if state.health < 1 do
      {:reply, false, state}
    else
      {:reply, true, state}
    end
  end

  @impl true
  def handle_call(:is_in_combat?, _from, state) do
    {:reply, state.in_combat, state}
  end

  @impl true
  def handle_call(:get_attack_damage, _from, state) do
    if state.weapon !== nil do
      value = Engine.Object.get_value({:global, Engine.Utilities.advanced_to_atom(state.weapon)})
      {:reply, 1 + value, state}
    else
      {:reply, 1, state}
    end
  end

  @impl true
  def handle_call(:get_inventory, _from, state) do
    {:reply, state.inventory, state}
  end

  @impl true
  def handle_call({:hit, health_points}, _from, state) do
    new_health = state.health - health_points

    new_state = %{state | health: new_health}

    {:reply, new_health, new_state}
  end

  @impl true
  def handle_cast({:add_exp, quantity}, state) do
    if state.level === 20 do
      {:noreply, state, state}
    else
      cond do
        state.level === 1 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.first_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.first_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 2 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.second_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.second_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 3 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.third_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.third_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 4 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.fourth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.fourth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 5 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.fifth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.fifth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 6 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.sixth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.sixth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 7 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.seventh_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.seventh_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 8 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.eigth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.eigth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 9 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.ninth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.ninth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 10 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.tenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.tenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 11 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.eleventh_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.eleventh_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 12 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.twelfth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.twelfth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 13 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.thirteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.thirteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 14 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.fourteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.fourteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 15 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.fifteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.fifteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 16 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.sixteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.sixteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 17 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.seventeenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.seventeenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 18 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.eighteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.eighteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        state.level === 19 ->
          total_exp = state.exp + quantity

          if total_exp >= Engine.Constants.nineteenth_level_limit() do
            level_up = state.level + 1
            new_state = %{state | level: level_up}
            new_state = %{new_state | exp: total_exp - Engine.Constants.nineteenth_level_limit()}
            {:noreply, new_state, state}
          else
            new_state = %{state | exp: total_exp}
            {:noreply, new_state, state}
          end

        true ->
          new_state = %{state | exp: state.exp + quantity}
          {:noreply, new_state, state}
      end
    end
  end

  @impl true
  def handle_cast({:add_to_inventory, object}, state) do
    if !Enum.member?(state.inventory, object) do
      new_state = %{state | inventory: [object | state.inventory]}
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:change_location, new_location}, state) do
    new_state = %{state | current_location: new_location}
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:equip_object, {object_name, object_type}}, state) do
    if Enum.member?(state.inventory, object_name) do
      cond do
        object_type === "head" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.head === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | head: object_name}
            {:noreply, new_state}
          else
            objects = [state.head | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | head: object_name}
            {:noreply, new_state}
          end

        object_type === "body" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.body === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | body: object_name}
            {:noreply, new_state}
          else
            objects = [state.body | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | body: object_name}
            {:noreply, new_state}
          end

        object_type === "arms" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.arms === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | arms: object_name}
            {:noreply, new_state}
          else
            objects = [state.arms | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | arms: object_name}
            {:noreply, new_state}
          end

        object_type === "legs" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.legs === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | legs: object_name}
            {:noreply, new_state}
          else
            objects = [state.legs | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | legs: object_name}
            {:noreply, new_state}
          end

        object_type === "feet" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.feet === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | feet: object_name}
            {:noreply, new_state}
          else
            objects = [state.feet | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | feet: object_name}
            {:noreply, new_state}
          end

        object_type === "weapon" ->
          objects = Enum.filter(state.inventory, fn element -> element !== object_name end)

          if state.weapon === nil do
            new_state = %{state | inventory: objects}
            new_state = %{new_state | weapon: object_name}
            {:noreply, new_state}
          else
            objects = [state.weapon | objects]
            new_state = %{state | inventory: objects}
            new_state = %{new_state | weapon: object_name}
            {:noreply, new_state}
          end
      end
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:change_combat_status, status}, state) do
    new_state = %{state | in_combat: status}
    {:noreply, new_state}
  end
end

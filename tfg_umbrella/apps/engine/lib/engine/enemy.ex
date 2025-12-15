defmodule Engine.Enemy do
  use GenServer

  @moduledoc """
  Definition of an engine enemy
  """

  @enforce_keys [:health, :attack_type]
  @derive Jason.Encoder
  defstruct level: 1,
            charisma: 1,
            wisdom: 1,
            intelligence: 1,
            constitution: 1,
            dexterity: 1,
            strength: 1,
            health: 100,
            attack_type: "",
            reward: 100

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

  def get_level(name) do
    GenServer.call(name, :get_level)
  end

  def get_attack_type(name) do
    GenServer.call(name, :get_attack_type)
  end

  def get_reward(name) do
    GenServer.call(name, :get_reward)
  end

  def is_alive?(name) do
    GenServer.call(name, :is_alive?)
  end

  def get_attack_damage(name) do
    GenServer.call(name, :get_attack_damage)
  end

  def hit(name, hit_points) do
    GenServer.call(name, {:hit, hit_points})
  end

  @impl true
  def init(%Engine.Enemy{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Enemy{
      level: initial_state["level"],
      charisma: initial_state["charisma"],
      wisdom: initial_state["wisdom"],
      intelligence: initial_state["intelligence"],
      constitution: initial_state["constitution"],
      dexterity: initial_state["dexterity"],
      strength: initial_state["strength"],
      health: initial_state["health"],
      attack_type: initial_state["attack_type"],
      reward: initial_state["reward"]
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
  def handle_call(:get_level, _from, state) do
    {:reply, state.level, state}
  end

  @impl true
  def handle_call(:get_attack_type, _from, state) do
    {:reply, state.attack_type, state}
  end

  @impl true
  def handle_call(:get_reward, _from, state) do
    if state.health < 1 do
      {:reply, state.reward, state}
    else
      {:reply, 0, state}
    end
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
  def handle_call(:get_attack_damage, _from, state) do
    if state.health > 0 do
      case state.attack_type do
        "charisma" ->
          {:reply, state.charisma, state}

        "wisdom" ->
          {:reply, state.wisdom, state}

        "intelligence" ->
          {:reply, state.intelligence, state}

        "constitution" ->
          {:reply, state.constitution, state}

        "dexterity" ->
          {:reply, state.dexterity, state}

        "strength" ->
          {:reply, state.strength, state}

        _ ->
          {:reply, 1, state}
      end
    else
      {:reply, 0, state}
    end
  end

  @impl true
  def handle_call({:hit, health_points}, _from, state) do
    new_health = state.health - health_points

    new_state = %{state | health: new_health}

    {:reply, new_health, new_state}
  end
end

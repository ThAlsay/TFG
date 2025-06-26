defmodule Engine.Enemy do
  use GenServer

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

  def start_link(default) do
    name = default["name"]
    init_arg = default["state"]

    if name === nil or init_arg === nil do
      {:error, "Error creating enemy. Name or initial state missing"}
    else
      GenServer.start_link(__MODULE__, init_arg, name: String.to_atom(name))
    end
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

  def attack(name) do
    GenServer.call(name, :attack)
  end

  def is_alive?(name) do
    GenServer.call(name, :is_alive?)
  end

  def get_attack_damage(name) do
    GenServer.call(name, :get_attack_damage)
  end

  def hit(name, hit_points) do
    GenServer.cast(name, {:hit, hit_points})
  end

  @impl true
  def init(initial_state) when is_struct(initial_state) do
    state = struct!(Engine.Enemy, initial_state)
    {:ok, state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) do
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
  def handle_call(:attack, _from, state) do
    {:reply, state.attack_type, state}
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
  end

  @impl true
  def handle_cast({:hit, health_points}, state) do
    new_health = state.health - health_points

    new_state = %{state | health: new_health}

    {:noreply, new_state}
  end
end

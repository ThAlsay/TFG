defmodule Engine.Npc do
  use GenServer

  @moduledoc """
  Definition of an engine npc.
  """

  @enforce_keys [:level, :interaction]
  @derive Jason.Encoder
  defstruct level: 1,
            charisma: 1,
            wisdom: 1,
            intelligence: 1,
            constitution: 1,
            dexterity: 1,
            strength: 1,
            interaction: nil,
            interaction_limit: nil

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

  def get_interaction(name) do
    GenServer.call(name, :get_interaction)
  end

  def interact(name) do
    GenServer.call(name, :interact)
  end

  def get_interaction_limit(name) do
    GenServer.call(name, :get_interaction_limit)
  end

  def modify_interaction_limit(name, limit) do
    GenServer.cast(name, {:modify_interaction_limit, limit})
  end

  @impl true
  def init(%Engine.Npc{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Npc{
      level: initial_state["level"],
      charisma: initial_state["charisma"],
      wisdom: initial_state["wisdom"],
      intelligence: initial_state["intelligence"],
      constitution: initial_state["constitution"],
      dexterity: initial_state["dexterity"],
      strength: initial_state["strength"],
      interaction: initial_state["interaction"],
      interaction_limit: initial_state["interaction_limit"]
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
  def handle_call(:get_interaction, _from, state) do
    {:reply, state.interaction, state}
  end

  @impl true
  def handle_call(:interact, _from, state) do
    cond do
      state.interaction_limit === nil || state.interaction_limit === 0 ->
        {:reply, true, state}

      state.interaction_limit !== 0 ->
        new_state = %{state | interaction_limit: state.interaction_limit - 1}
        {:reply, false, new_state}

      true ->
        {:stop, "wrong interaction limit type", state}
    end
  end

  @impl true
  def handle_call(:get_interaction_limit, _from, state) do
    {:reply, state.interaction_limit, state}
  end

  @impl true
  def handle_cast({:modify_interaction_limit, limit}, state) when is_integer(limit) do
    new_state = %{state | interaction_limit: limit}

    {:noreply, new_state}
  end
end

defmodule Engine.Location do
  use GenServer

  @moduledoc """
  Definition of an engine location.
  """

  @enforce_keys [:objects, :connections]
  @derive Jason.Encoder
  defstruct objects: [], connections: [], enemy: [], npc: nil

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

  def get_objects(name) do
    GenServer.call(name, :get_objects)
  end

  def get_connections(name) do
    GenServer.call(name, :get_connections)
  end

  def get_npc(name) do
    GenServer.call(name, :get_npc)
  end

  def get_enemy(name) do
    GenServer.call(name, :get_enemy)
  end

  def add_object(name, element) do
    GenServer.cast(name, {:add_object, element})
  end

  def remove_object(name, element) do
    GenServer.cast(name, {:remove_object, element})
  end

  def add_connection(name, element) do
    GenServer.cast(name, {:add_connection, element})
  end

  def add_npc(name, element) do
    GenServer.cast(name, {:add_npc, element})
  end

  def add_enemy(name, element) do
    GenServer.cast(name, {:add_enemy, element})
  end

  @impl true
  def init(%Engine.Location{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Location{
      objects: initial_state["objects"],
      connections: initial_state["connections"],
      npc: initial_state["npc"],
      enemy: initial_state["enemy"]
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_objects, _from, state) do
    objects = state.objects

    {:reply, objects, state}
  end

  @impl true
  def handle_call(:get_connections, _from, state) do
    connections = state.connections

    {:reply, connections, state}
  end

  @impl true
  def handle_call(:get_npc, _from, state) do
    {:reply, state.npc, state}
  end

  @impl true
  def handle_call(:get_enemy, _from, state) do
    response =
      Enum.filter(state.enemy, fn ene ->
        Engine.Enemy.is_alive?({:global, Engine.Utilities.advanced_to_atom(ene)})
      end)

    {:reply, response, state}
  end

  @impl true
  def handle_cast({:add_object, element}, state) do
    objects = state.objects
    objects = [element | objects]

    new_state = %{state | objects: objects}

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_object, object}, state) do
    new_state = %{
      state
      | objects: Enum.filter(state.objects, fn element -> element !== object end)
    }

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:add_connection, element}, state) do
    connections = state.connections
    connections = [element | connections]

    new_state = %{state | connections: connections}

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:add_npc, element}, state) do
    new_state = %{state | npc: element}

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:add_enemy, element}, state) do
    enemies = state.enemy
    enemies = [element | enemies]

    new_state = %{state | enemy: enemies}

    {:noreply, new_state}
  end
end

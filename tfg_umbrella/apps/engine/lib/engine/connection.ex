defmodule Engine.Connection do
  use GenServer

  @moduledoc """
  Definition of an engine connection between locations.
  """

  @enforce_keys [:level, :location_1, :location_2]
  @derive Jason.Encoder
  defstruct level: 1, location_1: nil, location_2: nil, object: nil

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

  def get_level(name) do
    GenServer.call(name, :get_level)
  end

  def get_next_location(name, current_location) do
    GenServer.call(name, {:get_next_location, current_location})
  end

  def get_object(name) do
    GenServer.call(name, :get_object)
  end

  # Callbacks
  @impl true
  def init(%Engine.Connection{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Connection{
      level: initial_state["level"],
      location_1: initial_state["location_1"],
      location_2: initial_state["location_2"],
      object: initial_state["object"]
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_level, _from, state) do
    {:reply, state.level, state}
  end

  @impl true
  def handle_call({:get_next_location, current_location}, _from, state) do
    cond do
      current_location == state.location_1 ->
        {:reply, state.location_2, state}

      current_location == state.location_2 ->
        {:reply, state.location_1, state}

      true ->
        {:reply, "error", state}
    end
  end

  @impl true
  def handle_call(:get_object, _from, state) do
    {:reply, state.object, state}
  end
end

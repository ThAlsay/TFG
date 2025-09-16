defmodule Engine.Object do
  use GenServer

  @moduledoc """
  Definition of an engine object
  """

  @enforce_keys [:level, :type]
  @derive Jason.Encoder
  defstruct level: 1, stat: nil, type: "", value: 0

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

  def get_stat_value(name) do
    GenServer.call(name, :get_stat_value)
  end

  def get_value(name) do
    GenServer.call(name, :get_value)
  end

  def get_type(name) do
    GenServer.call(name, :get_type)
  end

  @impl true
  def init(%Engine.Object{} = initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) and not is_struct(initial_state) do
    state = %Engine.Object{
      level: initial_state["level"],
      stat: initial_state["stat"],
      type: initial_state["type"],
      value: initial_state["value"]
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
  def handle_call(:get_stat_value, _from, state) do
    {:reply, {state.stat, state.value}, state}
  end

  @impl true
  def handle_call(:get_value, _from, state) do
    {:reply, state.value, state}
  end

  @impl true
  def handle_call(:get_type, _from, state) do
    {:reply, state.type, state}
  end
end

defmodule Engine.Object do
  use GenServer

  @enforce_keys [:level, :type]
  @derive Jason.Encoder
  defstruct level: 1, stat: nil, type: "", value: 0

  def start_link(default) do
    name = default["name"]
    init_arg = default["state"]

    if name === nil or init_arg === nil do
      {:error, "Error creating object. Name or initial state missing"}
    else
      GenServer.start_link(__MODULE__, init_arg, name: String.to_atom(name))
    end
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
  def init(initial_state) when is_struct(initial_state) do
    state = struct!(Engine.Object, initial_state)
    {:ok, state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) do
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

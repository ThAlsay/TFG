defmodule Engine.Connection do
  use GenServer

  @enforce_keys [:level, :location_1, :location_2]
  @derive Jason.Encoder
  defstruct level: 1, location_1: nil, location_2: nil, object: nil

  def start_link(default) do
    name = default["name"]
    init_arg = default["state"]

    if name === nil or init_arg === nil do
      {:error, "Error creating connection. Name or initial state missing"}
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

  def get_next_location(name, current_location) do
    GenServer.call(name, {:get_next_location, current_location})
  end

  def get_object(name) do
    GenServer.call(name, :get_object)
  end

  # Callbacks
  @impl true
  def init(initial_state) when is_struct(initial_state) do
    state = struct!(Engine.Connection, initial_state)
    {:ok, state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) do
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

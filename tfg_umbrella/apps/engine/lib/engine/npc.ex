defmodule Engine.Npc do
  use GenServer

  @enforce_keys [:level, :interaction]
  defstruct level: 1,
            charisma: 1,
            wisdom: 1,
            intelligence: 1,
            constitution: 1,
            dexterity: 1,
            strength: 1,
            interaction: nil

  def start_link(default) do
    name = default["name"]
    init_arg = default["state"]

    if name === nil or init_arg === nil do
      {:error, "Error creating NPC. Name or initial state missing"}
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

  def get_interaction(name) do
    GenServer.call(name, :get_interaction)
  end

  @impl true
  def init(initial_state) when is_struct(initial_state) do
    state = struct!(Engine.Npc, initial_state)
    {:ok, state}
  end

  @impl true
  def init(initial_state) when is_map(initial_state) do
    state = %Engine.Npc{
      level: initial_state["level"],
      charisma: initial_state["charisma"],
      wisdom: initial_state["wisdom"],
      intelligence: initial_state["intelligence"],
      constitution: initial_state["constitution"],
      dexterity: initial_state["dexterity"],
      strength: initial_state["strength"],
      interaction: initial_state["interaction"]
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
end

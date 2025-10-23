# Manual de desarrollo

| Documento: | Módulo-1: Manual de desarrollo                          |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Manual de desarrollo de Hephaestus                      |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | lunes, 20 de octubre de 2025                            |
| Versión:   | 0.1                                                     |

## Modificar una entidad

Si quiere modificar una entidad dentro del motor las definiciones de las mismas se encuentran en los archivos con sus correspondientes nombres
(character.ex, connection.ex, enemy.ex, location.ex, npc.ex y object.ex). Las definiciones de una entidad son Genservers de Elixir definidos cliente
y servidor en el mismo archivo. A continuación se muestra el ejemplo de la entidad "connection".

```elixir
defmodule Engine.Connection do
  use GenServer

  @enforce_keys [:level, :location_1, :location_2]
  @derive Jason.Encoder
  defstruct level: 1, location_1: nil, location_2: nil, object: nil

  # Inicializador del GenServer
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

  # Cliente del GenServer
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

  # Servidor del GenServer
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
```

### Añadir un nuevo método

Un Genserver puede tener métodos síncronos o asíncronos, los métodos síncronos devolveran una respuesta al emisor del mensaje, mientras que los
asíncronos simplemente modificaran el estado interno del actor sin devolver una respuesta.

Para añadir un método síncrono añada una implementación "handle_call" y su correspondiente llamada en la parte del cliente.

```elixir
# ... funciones de la parte del cliente
# "name" es el nombre del actor al que queremos mandarle el mensaje
# el nombre de la función no tiene por que coincidir con el átomo al que nos estemos refiriendo.
def say_hello(name) do
  GenServer.call(name, :say_hello)
end

# esta variación de lo de arriba también funcionaría
def hello(name) do
  GenServer.call(name, :say_hello)
end

# ... resto de handle_call
@impl true
def handle_call(:say_hello, _from, state) do
  {:reply, "hello world", state}
end
```

Para añadir un método asíncrono añada una implementación de "handle_cast" y su correspondiente llamada en la parte del cliente.

```elixir
# ... funciones de la parte del cliente
def do_nothing(name) do
  GenServer.cast(name, :do_nothing)
end

# ...resto de handle_cast
@impl true
def handle_cast(:do_nothing, state) do
  # modificaciones del estado resultantes en una variante "new_state"
  {:no_reply, new_state}
end
```

Si se quiere pasar cualquier argumento al método envuelva el nombre del método entre corchetes seguido del argumento. De la
siguiente forma:

```elixir
# ejemplo del say_hello pero con argumento
def say_hello(name, pretty_name) do
  GenServer.call(name, {:say_hello, pretty_name})
end

# ... resto de handle_call
@impl true
def handle_call({:say_hello, pretty_name}, _from, state) do
  {:reply, "hello #{pretty_name}", state}
end
```

### Eliminar un método

Para eliminar un método de un GenServer simplemente elimine la implementación del método a eliminar en la parte del servidor y
su llamada en la parte del cliente.

## Añadir una nueva entidad

La totalidad del juego se almacena como un archivo JSON dentro de la base datos siguiendo el siguiente schema:

```json
{
  "npcs": [
    {
      "name": string,
      "state": {
        "level": integer,
        "wisdom": integer,
        "charisma": integer,
        "strength": integer,
        "dexterity": integer,
        "constitution": integer,
        "intelligence": integer,
        "interaction": string | object,
        "interaction_limit": integer | null
      }
    }
  ],
  "enemies": [
    {
      "name": string,
      "state": {
        "level": integer,
        "health": float,
        "reward": float,
        "wisdom": integer,
        "charisma": integer,
        "strength": integer,
        "dexterity": integer,
        "constitution": integer,
        "intelligence": integer,
        "attack_type": string
      }
    }
  ],
  "objects": [
    {
      "name": string,
      "state": {
        "stat": string | null,
        "type": string,
        "level": integer,
        "value": float
      }
    }
  ],
  "locations": [
    {
      "name": string,
      "state": {
        "npc": string | null,
        "enemy": [string],
        "objects": [string],
        "connections": [string]
      }
    }
  ],
  "connections": [
    {
      "name": string,
      "state": {
        "level": integer,
        "object": string | null,
        "location_1": string,
        "location_2": string
      }
    }
  ]
}
```

Para añadir una entidad agrégela en su correspondiente lista y modifique el resto de entidades de acuerdo a las relaciones que tengan con
la recién añadida. La modificación ha de hacerse en ambas filas de la tabla "saves", antes de comenzar a usar el juego.

Si ya existe alguna partida guardada será decisión del desarrollador si modificar la partida guardada o reemplazarla por la nueva versión.

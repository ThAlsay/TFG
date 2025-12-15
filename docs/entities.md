# Entidades

## Iniciar una entidad

Toda entidad de Hephaestus sigue el esquema de una _GameEntity_.

```elixir
defmodule Engine.GameEntity do
  @derive Jason.Encoder
  defstruct [:name, :state]
end
```

El nombre de la entidad tiene que ser único, ya que es el identificador empleado para iniciar el _GenServer_. El estado es el mapa de la entidad concreta que 
se quiere crear.

La creación de una entidad sigue las reglas de inicio de cualquier _GenServer_ en elixir.

```elixir
Engine.DynamicSupervisor.start_child(:supervisor_id, {Engine.Character, %Engine.Character{}})
```

## Personaje

En el motor:

```elixir
# Definición del mapa
%Engine.Character{}

# Referencia
Engine.Character
```

### Atributos

- level: el nivel del personaje.
- charisma: puntos del atributo carisma.
- wisdom: puntos del atributo sabiduría.
- intelligence: puntos del atributo inteligencia.
- constitution: puntos del atributo constitución.
- dexterity: puntos del atributo destreza.
- strength: puntos del atributo fuerza.
- health: puntos de vida. Al llegar a cero se da por muerto al personaje.
- exp: puntos de experiencia.
- inventory: lista de identificadores de objetos que porta el personaje.
- head: identificador del objeto que tiene equipado en la cabeza el personaje. Puede no tener ninguno.
- body: identificador del objeto que tiene equipado en el torso el personaje. Puede no tener ninguno.
- arms: identificador del objeto que tiene equipado en los brazos el personaje. Puede no tener ninguno.
- legs: identificador del objeto que tiene equipado en las piernas el personaje. Puede no tener ninguno.
- feet: identificador del objeto que tiene equipado en los pies el personaje. Puede no tener ninguno.
- weapon: identificador del arma equipada por el personaje. Puede no tener ninguna.
- missions: lista de identificadores de misiones aceptadas por el personaje. El motor no cuenta con misiones, tienen que ser programadas si así lo 
  desea el creador del juego.
- current_location: identificador de la localización en la que se encuentra actualmente el personaje.
- in_combat: verdadero si el personaje está en combate con un enemigo o falso en caso contrario.

### Funciones

#### Getters

Las funciones _getter_ extraen algún atributo del personaje:

- get_state: todos los atributos.
- get_stats: charisma, wisdom, intelligence, constitution, dexterity, strength.
- get_health: puntos de vida del personaje.
- get_exp: puntos de experiencia.
- get_level: nivel del personaje.
- get_current_location: ubicación actual.
- is_alive?: estado del personaje. Verdadero si vivo, falso si muerto.
- is_in_combat?: estado de combate. Verdadero si en combate, falso si no.
- get_attack_damage: valor calculado de daño que inflige el personaje.
- get_inventory: el inventario del personaje.

#### Hit

La función _hit_ resta los puntos de daño que recibe el personaje a su vida.

Parámetros:

- hit_points: puntos de daño.

#### Add_exp

La función _add\_exp_ añade puntos de experiencia al personaje y sube de nivel al mismo. Función asíncrona.

Parámetros:

- exp: puntos de experiencia.

#### Add_to_inventory

La función _add\_to\_inventory_ añade el identificador de un objeto al inventario. Función asíncrona.

Parámetros:

- element: identificador del objeto en formato _string_.

#### Change_location

La función _change\_location_ mueve al personaje de ubicación. Función asíncrona.

Parámetros:

- location: identificador de la ubicación a la que se mueve el personaje.

#### Equip_object

La función _equip\_object_ equipa un objeto del inventario en uno de los posibles huecos de equipamiento del personaje. Función asíncrona.

Parámetros:

- object: identificador del objecto.
- type: hueco en el que se equipa el objeto. Puede ser: "head", "body", "arms", "legs", "feet" o "weapon".

#### Change_combat_status

La función _change\_combat\_status_ cambia si el personaje está en combate o no. Función asíncrona.

Parámetros:

- status: true o false.

## Conexión

En el motor:

```elixir
# Definición del mapa
%Engine.Connection{}

# Referencia
Engine.Connection
```

### Atributos

- level: nivel necesario para atravesar la conexión.
- location_1: identificador de una de las dos ubicaciones que conecta la conexión.
- location_2: identificador de la otra ubicación.
- object: objeto necesario para atravesar la conexión. Puede ser nulo.

### Funciones

#### Getters
Las funciones _getter_ extraen algún atributo de la conexión:

- get_state: todos los atributos.
- get_level: nivel necesario para cruzar.
- get_object: objeto necesario para cruzar.

#### Get_next_connection

La función _get\_next\_location_ devuelve la ubicación conectada al otro extremo desde la ubicación.

Parámetros:

- current_location: identificador de la ubicación de origen.

## Enemigo

En el motor:

```elixir
# Definición del mapa
%Engine.Enemy{}

# Referencia
Engine.Enemy
```

### Atributos

- level: el nivel del enemigo.
- charisma: puntos del atributo carisma.
- wisdom: puntos del atributo sabiduría.
- intelligence: puntos del atributo inteligencia.
- constitution: puntos del atributo constitución.
- dexterity: puntos del atributo destreza.
- strength: puntos del atributo fuerza.
- health: puntos de vida. Al llegar a cero se da por muerto al enemigo.
- attack_type: atributo empleado para calcular el daño que hace el enemigo. Puede ser: "charisma", "wisdom", "intelligence", "constitution", "dexterity" o "strength".
- reward: cantidad de experiencia que da al morir.

### Funciones

#### Getters

Las funciones _getter_ extraen algún atributo del enemigo:

- get_state: todos los atributos.
- get_stats: charisma, wisdom, intelligence, constitution, dexterity, strength.
- get_health: puntos de vida del enemigo.
- get_level: nivel del enemigo.
- get_attack_type: tipo de ataque.
- get_reward: puntos de experiencia que otorga al derrotarlo.
- is_alive?: verdadero si el enemigo sigue con vida, falso si no.
- get_attack_damage: daño que hace el enemigo.

#### Hit

La función _hit_ resta los puntos de daño que recibe el enemigo a su vida.

Parámetros:

- hit_points: puntos de daño.

## Ubicación

En el motor:

```elixir
# Definición del mapa
%Engine.Location{}

# Referencia
Engine.Location
```

### Atributos

- objects: lista de identificadores de objetos que están en la ubicación.
- connections: lista de identificadores de conexiones que conectan con la ubicación.
- npc: identificador del NPC que se encuentra en la ubicación. Puede ser nulo.
- enemy: lista de identificadores de enemigos que se encuentran en la ubicación.

### Funciones

#### Getters

Las funciones _getter_ extraen algún atributo del enemigo:

- get_state: todos los atributos.
- get_objects: objetos en la ubicación.
- get_connections: conexiones de la ubicación.
- get_npc: NPC de la ubicación.
- get_enemy: enemigos de la ubicación.

#### Add_object

La función _add\_object_ añade un objeto a la ubicación. Función asíncrona.

Parámetros:

- element: identificador del objeto a añadir a la ubicación.

#### Remove_object

La función _remove\_object_ elimina un objeto de la ubicación. Función asíncrona.

Parámetros:

- element: identificador del objeto a eliminar a la ubicación.

#### Add_connection

La función _add\_connection_ añade una conexión a la ubicación. Función asíncrona.

Parámetros:

- element: identificador de la conexión a añadir a la ubicación.

#### Add_npc

La función _add\_npc_ añade un NPC a la ubicación. Función asíncrona.

Parámetros:

- element: identificador del NPC a añadir a la ubicación.

#### Add_enemy

La función _add\_enemy_ añade un enemigo a la ubicación. Función asíncrona.

Parámetros:

- element: identificador del enemigo a añadir a la ubicación.

## NPC

En el motor:

```elixir
# Definición del mapa
%Engine.Npc{}

# Referencia
Engine.Npc
```

### Atributos

- level: el nivel del NPC.
- charisma: puntos del atributo carisma.
- wisdom: puntos del atributo sabiduría.
- intelligence: puntos del atributo inteligencia.
- constitution: puntos del atributo constitución.
- dexterity: puntos del atributo destreza.
- strength: puntos del atributo fuerza.
- interaction: interacción que realiza el NPC.
- interaction_limit: limite de interacciones con el NPC. Puede ser nulo.

### Funciones

#### Getters

Las funciones _getter_ extraen algún atributo del NPC:

- get_state: todos los atributos.
- get_stats: charisma, wisdom, intelligence, constitution, dexterity, strength.
- get_interaction: la interacción que realiza el NPC.
- get_interaction_limit: el límite de interacciones del NPC.

#### Interact

La función _interact_ interactua con el NPC y disminuye el límite en 1 si tiene.

#### Modify_interaction_limit

La función _modify\_interaction\_limit_ modifica el límite de interacciones del NPC. Función asíncrona.

Parámetros:

- limit: número de interacciones.

## Objeto

### Atributos

- level: el nivel del objeto.
- stat: estadística a la que afecta.
- tipo: tipo de objeto. Si es equipable, la parte del personaje en la que se equipa.
- value: valor del efecto que realiza el objeto.

### Funciones

#### Getters

Las funciones _getter_ extraen algún atributo del objeto:

- get_state: todos los atributos.
- get_level: el nivel del objeto.
- get_value: valor del efecto del objeto.
- get_type: tipo del objeto.
- get_stat_value: tupla de la estadística a la que afecta el objeto y su valor.
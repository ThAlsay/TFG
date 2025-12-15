# Estructura

Al tratarse de un motor opinionado y específico, el motor cuenta con una serie de elementos que permiten crear juegos concretos.

## Base

La base sobre la que se construyen todos los elementos interactuables del juego, y de los cuales el motor está encargado, está basadas en la librería _GenServer_ de
Elixir. Cada entidad jugable es un una instancia concreta construida siguiendo el modelo que plantea Elixir para un _GenServer_.

A esta base la acompañan una serie de complementos que permiten la conexión con la base de datos, la cual almacena el estado del juego, o la decisión de turnos.

## Entidades

Una entidad es una parte del juego que almacena, modifica o elimina un estado. Como ya se ha mencionado, las entidades emplean un _GenServer_ para almacenar y modificar
el estado. El motor está encargado de definir las entidades disponibles para su creación, así como los métodos necesarios para modifcar o leer el estado.

La lista de entidades disponibles en Hephaestus es:

- Personajes
- Enemigos
- NPCs
- Estancias
- Objetos
- Conexiones

## Otros elementos

Además de la definición de entidades, el motor cuenta con otros elementos para ayudar en el desarrollo de los videojuegos.

### Dados

El motor cuenta con un dado para otorgar turnos de combate entre un personaje y un enemigo. Dicho dado no es completamente aleatorio, basa el porcentaje de que el
turno sea para el personaje o el enemigo a partir de sus niveles. Si los niveles son iguales la probabilidad para que caiga en uno de los lados es de 50%. Cada
nivel de diferencia suma un 5% para el lado con el nivel superior, hasta un máximo de 95% de probabilidad. Por ejemplo: si el personaje es nivel 3 y el enemigo nivel
5 hay una probabilidad de que el dado escoja al enemigo del 60%. Si el mismo personaje sube al nivel 4 antes de la pelea, la probabilidad de que le toque al enemigo
pasa a ser del 55%.

### Base de Datos

El motor cuenta con las funciones necesarias para almacenar la información del juego en una base de datos postgres. De esta manera se puede almacenar el estado del
juego de forma permanente. La definición de las tablas de la base de datos es la siguiente:

```sql
CREATE TABLE public.players (
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    "character" jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);

CREATE TABLE public.saves (
    id character varying(255) NOT NULL,
    safe jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
```

La tabla _players_ almacena la información de los jugadores incluyendo el estado de su personaje. La tabla _saves_ almacena el estado del mundo inicial así como el
correspondiente a cada personaje, si se trata de un juego con mundo individual, o el estado actual del mundo, si se trata de un juego con mundo compartido por todos
los personajes.

### Supervisor

Si no se quiere administrar los _GenServer_ de manera estática en el juego, el motor incluye un supervisor dinámico para iniciar los _GenServer_.
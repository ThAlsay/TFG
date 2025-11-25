# Práctica 3.

| Documento: | Módulo-3: Desarrollo en Elixir                          |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Enunciado 3: Modificación del motor Hephaestus.         |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | sabado, 20 de septiembre de 2025                        |
| Versión:   | 0.1                                                     |

## Tabla de contenidos

- [Práctica 3.](#práctica-3)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Objetivo](#objetivo)
  - [La situación](#la-situación)
  - [Elixir](#elixir)
  - [Puesta en práctica](#puesta-en-práctica)
      - [Programando en Elixir](#programando-en-elixir)
      - [Volvemos a Java](#volvemos-a-java)
          - [Tabla de primitivas](#tabla-de-primitivas)

## Objetivo

En esta última práctica vamos a ver un poco más de cerca con que hemos estado jugando. Tocaremos el motor para poder pasarnos el juego.

## La situación

Tras la finalización de la práctica anterior nos encontrabamos en la habitación con tres conexiones tras haber conseguido la `llave` del `sabio`.

Tras la conexión bloqueada con `llave` se ubica la última sala del juego. Vamos a entrar a la sala y derrotar al enemigo empleando todo lo aprendido
hasta ahora. Si hemos hecho las cosas anteriores el enemigo debería caer derrotado al primer ataque.

Una vez derrotado el enemigo nos damos cuenta que no hay nada por el logro de haberlo derrotado. Asique, ya que el juego no nos da un trofeo, vamos
a arreglarlo para que ese no sea el caso.

Nos vamos a adentrar en el motor del juego y vamos a programar en Elixir un trofeo para que Tim recoja el fruto de sus esfuerzos.

## Elixir

Elixir es un lenguaje de programción que sigue el paradigma de programación funcional. Está diseñado para ser concurrente, de propósito general e
introduce características que no se ven en Java.

Algunas de las características de Elixir incluyen _pattern matching_, es decir, el operador `=` actúa de la misma forma que en matemáticas,
ambos lados del símbolo tienen que ser lo mismo, esto permite la asignación de variables, pero estas son inmutables, una vez se asigna un valor este no
se puede cambiar. A parte de la asignación de variables, el "pattern matching" permite definir la misma función varias veces con distintos argumentos o
con guardas como en el siguiente ejemplo.

```elixir
def fib(n) when n in [0, 1], do
  n
end

def fib(n), do
  fib(n-2) + fib(n-1)
end
```

Otra de las características que lo diferencian de lenguajes como Java es que no tiene bucles. Para poder realizar un bucle en Elixir hay que emplear técnicas
de recursividad para lograr el objetivo.

Relevante para la práctica es también el hecho que la devolución del resultado de una función no requiere de una palabra reservada si no que será el resultado
de la última evaluación del código de la misma. Por ejemplo:

```elixir
def devuelve_hola_string() do
  "hola" # <- Este es el último elemento evaluado de la función por lo tanto es lo que devuelve
end

# La función suma es tan fácil como devolver la expresión de la suma de los dos parámetros
def suma(num1, num2) do
  num1 + num2 # <- Último elemento evaluado
end

# También podemos devolver los resultados de otra función
def devuelve_resultado_funcion() do
  numero = suma(2, 4)
  numero
end

# Se puede omitir la asignación a una variable y evaluar directamente la función
def devuelve_resultado_funcion() do
  suma(2, 4)
end
```

Cabe destacar también el motivo principal por el que empleamos este lenguaje para el motor del juego y para el juego mismo y es la inclusión de `GenServer` en
la biblioteca estándar del lenguaje. Un `GenServer` es, para nosotros, el equivalente a un actor, cumple esa función dentro del juego.

Para más información visita la página oficial de Elixir en la que se pueden ver varios ejemplos de como funciona el lenguaje.
https://hexdocs.pm/elixir/1.19.1/introduction.html

## Puesta en práctica

Una vez sabemos como funciona Elixir vamos a programar nuestro `trofeo` y hacer que Tim lo recoja.

#### Programando en Elixir

Dentro de "tfg_umbrella/apps/engine" encontramos el fichero "location.ex", aquí se encuentra el `GenServer` que define el comportamiento de una habitación.
La función que buscamos en concreto es la función `handle_call(:get_enemy, _from, state)`. En esta función ya vemos una característica de los actores y es la
comunicación entre ellos.

```elixir
@impl true
def handle_call(:get_enemy, _from, state) do
  response =
    Enum.filter(state.enemy, fn ene ->
      Engine.Enemy.is_alive?({:global, Engine.Utilities.advanced_to_atom(ene)}) # <- En esta línea nos comunicamos con los actores que representan los enemigos
    end)

  {:reply, response, state}
end
```

Ahora vamos a modificar esta función para que cree un actor desde la misma (otra de las características que hemos visto de los actores es que pueden crear otros
actores) que va a ser el actor objeto `trofeo`. Para ello la definición del actor es la siguiente:

```elixir
%Engine.GameEntity{
  name: "trofeo",
  state: %Engine.Object{
    level: 1,
    stat: nil,
    type: "inventory_item",
    value: nil
  }
}
```

Los pasos que tenemos que seguir son:

  1. Comprobar que el número de enemigos es mayor que 0. A continuación vemos como es la estructura condicional. En caso de que no se cumpla la condición, 
    en este ejercicio en concreto, vamos a simplemente responder con el resultado `response` de la siguiente manera `{:reply, response, state}`.

  ```elixir
  if condition do
    # Se cumple la condición
  else
    # No se cumple la condición (opcional)
  end
  ```

  2. Si son mayor que 0 comprobar que el resultado de `response` arriba es igual a 0.

  3. Si se cumple la premisa anterior, iniciar el objeto como hijo del supervisor dinámico del motor:

  ```elixir
  DynamicSupervisor.start_child(Engine.Supervisor, {Engine.Object, definicion_objeto}) # La definición que hemos visto antes
  ```

  4. Una vez iniciado el actor objeto, modificar el estado de la propia habitación para que muestre trofeo como un objeto que se encuentra en ella.

Para resolver el último punto vamos a hacer que cambie el estado del actor. Cuando respondemos con `{:reply, response, state}` le estamos diciendo al `Genserver` 
que tiene que es una llamada síncrona (`:reply`), qué es lo que tiene que responder a la llamada (`response`) y como modifica esta llamada el estado del actor. 

Hasta ahora ninguno de los caminos que podía seguir modificaba el estado interno del actor, simplemente devolvía información del mismo, por eso el tercer parámetro 
es el mismo estado que ya tenía: `state`.

Este último camino si que nos lleva a modificar el estado interno del actor, ya que hay que incluir el `trofeo` en la habitación. Por lo tanto tenemos que saber
algunas cosas nuevas. En primer lugar, el estado de todos los actores del juego son mapas clave-valor que en Elixir se representan por `%{}` y sus claves pueden ser
un `atom` (`:ejemplo`) o un `string` (`"ejemplo"`). En segundo lugar, ya hemos dicho que las variables de Elixir son inmutables, esto incluye a la variable `state`
que contiene el estado del actor, por consiguiente vamos a tener que crear una nueva variable `new_state` que contenga la modificación al estado.

Sabiendo que la clave que tenemos que modificar es `:objects` y el valor es `["trofeo"]`, completa la siguiente expresión: `new_state = %{...}`. Para saber como se
modifica un valor de una clave de un mapa investiga en la documentación oficial (https://hexdocs.pm/elixir/Map.html).

Una vez modificado el estado, la respuesta final del camino será: `{:reply, response, new_state}`.

De esta forma la habitación en la que se encuentra nuestro personaje creará un actor `object` con nombre `trofeo` una vez derrotemos al enemigo.

#### Volvemos a Java

Una vez tenemos un nuevo motor que nos va a proporcionar un premio cuando completemos el juego vamos a hacer eso mismo, finalizar el juego. Para ello, en primer lugar
tenemos que construir la nueva imagen del motor y del juego tal y como se detalla en la práctica 0 y, después programar un cliente Java que ejecute las primitivas
necesarias para realizar la siguiente secuencia (empezamos desde la habitación de la práctica anterior):

  1. Viajar a la localización `habitacion_cueva_2`.
  2. Atacar al enemigo que se encuentra dentro de dicha habitación.
  3. Comprobar el estado de nuestro personaje tras el combate.
  4. Inspeccionar la habitación en busca de nuestro `trofeo`.
  5. Recoger el `trofeo`.

Para completar esta última parte de la práctica contamos con la siguiente tabla con todas las primitivas que permite el servidor.

###### Tabla de primitivas

| Primitiva                | Respuesta / Acción              | Parámetros                  | Explicación parámetro                                                |
| ------------------------ | ------------------------------- | --------------------------- | -------------------------------------------------------------------- |
| inspect_current_location | estado de la ubicación actual   | character_name              | nombre del personaje con el que estamos jugando                      |
| cross_connection         | cambia de estancia al personaje | connection / character_name | nombre de la conexión / nombre del personaje                         |
| take_object              | recoge un objeto de la estancia | object / character_name     | nombre del objeto / nombre del personaje                             |
| equip_object             | equipa el objeto al personaje   | object / character_name     | nombre del objeto / nombre del personaje                             |
| inspect_character        | estado del personaje            | character_name              | nombre del personaje                                                 |
| interact                 | interactúa con un NPC           | npc / character_name        | nombre del NPC / nombre del personaje con el que estamos jugando     |
| attack                   | ataca a un enemigo de la sala   | enemy / character_name      | nombre del enemigo / nombre del personaje con el que estamos jugando |
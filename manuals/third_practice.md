# Práctica 3.

| Documento: | Módulo-3: Desarrollo en Elixir                          |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Enunciado 3: Modificación del motor Hephaestus.         |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | sabado, 20 de septiembre de 2025                        |
| Versión:   | 0.1                                                     |

## Tabla de contenidos

## Introducción

En esta última práctica vamos a ver un poco más de cerca con que hemos estado jugando. Tocaremos el motor para poder pasarnos el juego.

## La situación

Tras la finalización de la práctica anterior nos encontrabamos en la habitación con tres conexiones tras haber conseguido la llave del sabio.

Tras la conexión bloqueada con llave se ubica la última sala del juego. Vamos a entrar a la sala y derrotar al enemigo empleando todo lo aprendido
hasta ahora. Si hemos hecho las cosas anteriores el enemigo debería caer derrotado al primer ataque.

Una vez derrotado el enemigo nos damos cuenta que no hay nada por el logro de haberlo derrotado. Asique, ya que el juego no nos da un trofeo, vamos
a arreglarlo para que ese no sea el caso.

Nos vamos a adentrar en el motor del juego y vamos a programar en Elixir un trofeo para que Tim recoja el fruto de sus esfuerzos.

## Elixir

Elixir es un lenguaje de programción que sigue el paradigma de programación funcional. Está diseñado para ser concurrente, de propósito general e
introduce características que no se ven en Java.

Algunas de las características de Elixir incluyen "pattern matching", es decir, el operador "=" funciona actúa de la misma forma que en matemáticas,
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

Cabe destacar también el motivo principal por el que empleamos este lenguaje para el motor del juego y para el juego mismo y es la inclusión de "GenServer" en
la biblioteca estándar del lenguaje. Un "GenServer" es, para nosotros, el equivalente a un actor, cumple esa función dentro del juego.

Para más información visita la página oficial de Elixir en la que se pueden ver varios ejemplos de como funciona el lenguaje.
https://hexdocs.pm/elixir/1.19.1/introduction.html

## Puesta en práctica

Una vez sabemos como funciona Elixir vamos a programar nuestro trofeo y hacer que Tim lo recoja.

Dentro de "tfg_umbrella/apps/engine" encontramos el fichero "location.ex", aquí se encuentra el GenServer que define el comportamiento de una habitación.
La función que buscamos en concreto es la función "handle_call(:get_enemy, \_from, state)". En esta función ya vemos una característica de los actores y es la
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
actores) que va a ser el actor objeto trofeo. Para ello la definición del actor es la siguiente:

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

1 - Comprobar que el número de enemigos es mayor que 0.

2 - Si son mayor que 0 comprobar que el resultado de "response" arriba es igual a 0.

3 - Iniciar el objeto como hijo del supervisor dinámico del motor:

```elixir
DynamicSupervisor.start_child(Engine.Supervisor, ...  )
```

4 - Una vez iniciado el actor objeto, modificar el estado de la propia habitación para que muestre trofeo como un objeto que se encuentra en ella.

Una vez hemos hecho todo esto construimos la imagen del motor como se detalla en el README.md y ejecutamos la secuencia entera mediante mensajes enviados con un
cliente de Java que nos permitan derrotar al enemigo, inspeccionar la habitación y recoger el objeto de la misma.

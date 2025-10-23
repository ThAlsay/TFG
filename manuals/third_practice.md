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

## Puesta en práctica

Una vez sabemos como funciona Elixir vamos a programar nuestro trofeo y hacer que Tim lo recoja.

Dentro de "tfg_umbrella/apps/engine" encontramos el fichero "location.ex", aquí se encuentra el GenServer que define el comportamiento de una habitación.
La función que buscamos en concreto es la función "handle_cast({:add_object, element}, state)"

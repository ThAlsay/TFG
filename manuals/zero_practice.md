# Práctica 0

| Documento: | Módulo-0: Presentación de las prácticas                 |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Enunciado 0: Presentación de las prácticas              |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | Viernes, 28 de Noviembre de 2025                        |
| Versión:   | 0.2                                                     |

## Tabla de contenidos

- [Práctica 0](#práctica-0)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Objetivos](#objetivos)
  - [El escenario](#el-escenario)
  - [La presentación de las páginas](#la-presentación-de-las-páginas)
    - [Práctica 1](#práctica-1)
    - [Práctica 2](#práctica-2)
    - [Práctica 3](#práctica-3)
  - [Elementos necesarios](#elementos-necesarios)
    - [Docker](#docker)
      - [Windows / MacOs / Linux (Docker Desktop)](#windows--macos--linux-docker-desktop)
      - [Linux (Docker Engine) / WSL](#linux-docker-engine--wsl)
    - [Java](#java)
    - [Elixir](#elixir)


## Objetivos

En este documento encontramos los objetivos que vamos a intentar cumplir a lo largo de las siguientes tres prácticas.
También contiente una guía para instalar todo lo que vamos a necesitar para poder realizar las prácticas.

## El escenario

Con la excusa de aprender sobre sistemas distribuidos vamos a jugar a un pequeño juego de rol por la línea de comandos. En este juego somos Tim, un aventurero
que se adentra en una cueva para intentar encontrar algún objeto de valor.

En este contexto vamos a utilizar Java y Elixir para jugar, ya veremos cómo.

## La presentación de las páginas

### Práctica 1

En esta primera práctica tenemos como objetivo aprender sobre la arquitectura de sistemas distribuidos cliente-servidor y el protocolo JSON-RPC. Para ello vamos a
hacer uso de Java para programar un cliente que se comunique con nuestro juego.

### Práctica 2

En la segunda práctica avanzaremos en elementos de los sistemas distribuidos, como son los actores y las colas de mensajes. En esta práctica seguiremos usando
Java para, en este caso, múltiples clientes que se comunican de manera simultánea con el juego.

### Práctica 3

En la última vamos a profundizar en los conceptos de la práctica anterior modificando el propio juego, esta vez empleando Elixir. Veremos el empleo de los actores,
programación en Elixir y finalizaremos el juego con otro cliente de Java.

## Elementos necesarios

### Docker

#### Windows / MacOs / Linux (Docker Desktop)

En Windows y MacOs docker solo está disponible mediante Docker Desktop. Para instalarlo sigue las instrucciones oficiales: https://docs.docker.com/get-started/get-docker/

Existe también una versión para Linux, aunque si trabajas desde WSL hay que seguir las instrucciones del siguiente apartado.

#### Linux (Docker Engine) / WSL

Este es el único método mediante el cuál podemos tener docker en WSL. Docker Engine instala únicamente los comandos por terminal sin aplicación de escritorio y solo
está disponible para Linux.

Al igual que con Docker Desktop, Docker proporciona instrucciones oficiales y detalladas sobre como instalarlo: https://docs.docker.com/engine/install/

### Java

Para programar en Java vamos a necesitar el JDK de Oracle, el cuál se puede descargar desde este enlace: https://www.oracle.com/es/java/technologies/downloads/#jdk25-linux

Si nos encontramos en Linux/WSL el enlace anterior contiene paquetes para Debian y derivados y RedHat y derivados (.deb y .rpm), pero el JDK se puede encontrar
normalmente en los repositorios de las distintas distribuciones. Esta suele ser una forma más sencilla de instalarlo.

### Elixir

La página web oficial de Elixir proporciona guías especificas para cada sistema operativo. https://elixir-lang.org/install.html
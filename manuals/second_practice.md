# Práctica 2.

| Documento: | Módulo-2: Actores y colas de mensaje                    |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Enunciado 2: Actores y colas de mensaje.                |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | sabado, 20 de septiembre de 2025                        |
| Versión:   | 0.1                                                     |

## Tabla de contenidos

- [Práctica 2.](#práctica-2)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Objetivo](#objetivo)
  - [Actores en los sistemas distribuidos](#actores-en-los-sistemas-distribuidos)
          - [Recepción de un mensaje por un actor (imagen de la teoría)](#recepción-de-un-mensaje-por-un-actor-imagen-de-la-teoría)
  - [Las colas de mensajes](#las-colas-de-mensajes)
  - [Aplicación en el juego](#aplicación-en-el-juego)
  - [Poner la teoría en práctica](#poner-la-teoría-en-práctica)
      - [Nuestro amigo el sabio](#nuestro-amigo-el-sabio)
      - [No era tan amigo el sabio](#no-era-tan-amigo-el-sabio)
      - [Abrumar al sabio](#abrumar-al-sabio)
      - [Finalizando la práctica](#finalizando-la-práctica)
          - [Tabla de primitivas](#tabla-de-primitivas)

## Objetivo

Durante esta práctica vamos a profundizar en los actores que ya hemos visto en clase, como funciona una cola de mensajes, la aplicación de todos estos conceptos 
en el juego y, finalmente, emplearemos todo ese conocimiento y el adquirido en la práctica anterior para programar clientes simultáneos en Java.

## Actores en los sistemas distribuidos

Como ya hemos visto en la teoría los actores son unidades de cómputo que representan una parte de la lógica de la aplicación.
Cada actor cuenta con una dirección para interactuar con él mediante llamadas a funciones, estas funciones mandan un mensaje asíncrono al actor
y este lo almacena en una cola de mensajes. De esta cola de mensajes el actor va procesando cada mensaje y manda el resultado del proceso de vuelta al
remitente si este lo había solicitado en el mensaje.

Hemos visto cuatro posibles modelos de actores: el modelo clásico, el modelo de objetos activos, el modelo de procesos y los bucles de eventos de comunicación actores 
y objetos. El juego al que estamos jugando está escrito en Elixir, por lo tanto estamos ante un modelo de procesos.
Es decir, cada vez que creamos un actor dentro del juego este levanta un nuevo proceso dentro del ámbito del programa y devuelve la dirección en la que el proceso
ha sido creado. Mediante esta dirección podemos enviar mensajes al actor e interactuar con él.

En el caso de Elixir podemos hacer que esta dirección se guarde en un almacén global de direcciones y cualquier programa de Elixir que forme parte de la red
puede acceder a este almacén y comunicarse de forma remota con otros programas. Esta es una de las formas que tiene Elxir de facilitar la programación
de sistemas distribuidos.

###### Recepción de un mensaje por un actor (imagen de la teoría)

![Actor](./images/actor_second_manual.jpg)

## Las colas de mensajes

Una de las partes que hemos visto de los actores es la cola de mensajes, la cual sirve para gestionar el procesamiento de varios mensajes que llegan simultáneamente o
mientras el actor está procesando otro mensaje. Una vez el actor está libre, procesa el mensaje y responde si así lo indica la acción ejecutada a raíz del mensaje.

En nuestro caso las colas de mensajes son FIFO (First In First Out) lo que quiere decir que la prioridad de procesamiento de los mensajes depende del orden en el que
llegan a la cola de mensajes, siendo los primeros en llegar los primeros que se procesan.

## Aplicación en el juego

Ya sabemos que estamos utilizando actores para que el juego funcione como un sistema distribuido y que este está escrito en Elixir, también sabemos como funcionan las 
colas de mensajes de los actores, ahora vamos a ver como empleamos los actores exactamente. Como ya vimos en la práctica anterior, el juego está compuesto por varias 
entidades cada cual representa un elemento del juego. Una habitación, un objeto o nuestro propio personaje son ejemplos de entidades que conforman el juego.

A parte de las entidades, existen partes del juego que no actúan como actores. Estas partes pueden incluir el acceso a la base de datos o la gestión de los
propios actores. De esto podemos deducir que, al decidirnos por una arquitectura distribuida que emplee actores, no todas la partes del sistema se van a regir por las
características de estos y podemos combinarlos con otros patrones de diseño arquitectónico de sistemas distribuidos.

## Poner la teoría en práctica

#### Nuestro amigo el sabio

Ahora vamos a poner en práctica lo visto en los apartados anteriores. Si hemos seguido la práctica anterior deberiamos estar en la habitación `habitacion_cueva_3`.
En esta habitación si empleamos la primitiva de la practica anterior `inspect_current_location` podemos observar que hay un NPC llamado `sabio` y como ya sabemos que
toda entidad del juego es un actor, el `sabio` también lo es. Esto nos permite deducir también que cuenta con una cola de mensajes.
Vamos a interactuar con él, para ello podemos emplear un cliente como el que se muestra a continuación.

```java
public class EjemploInteractuar {
  public static void main(String[] args) throws IOException, InterruptedException, ExecutionException {
    Gson jsonParser = new Gson();

    Socket socket = new Socket("localhost", 3000);
    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    interactWithNpc(jsonParser, out, in);
    socket.close();
  }

  private static void interactWithNpc(Gson jsonParser, PrintWriter out, BufferedReader in)
      throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("npc", "sabio");
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "interact");
    mapa.put("params", params);
    mapa.put("id", "1");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(),
        new TypeToken<HashMap<String, Object>>() {
        }.getType());

    printServerResult(respuesta);
  }

  private static void printServerResult(HashMap<String, Object> mapa) {
    Object resultado = mapa.get("result");
    Object error = mapa.get("error");
    Object id = mapa.get("id");

    if (resultado == null) {
      if (error == null) {
        System.out.println("Algo salio mal en el servidor \n");
      } else {
        System.out.println("Error al realizar la accion del mensaje con id " + id + ": " + error + "\n");
      }
    } else {
      System.out.println("Resultado del mensaje con id " + id + ": " + resultado + "\n");
    }
  }
}
```

Prueba a interactuar con él.

#### No era tan amigo el sabio

El sabio no parece muy por la labor de colaborar, habrá que insistir más. Para ello vamos a hacer uso de lo aprendido y a dejarle varios mensajes en 
su cola de mensajes.

El objetivo de esta práctica es conseguir que el `sabio` no nos ignore y nos entregue la `llave` que necesitamos para avanzar a la última habitación del juego. 
Para ello tenemos varias opciones. La primera y más obvia es meter el envío de mensajes en un bucle for y listo, pero, aunque funciona, no hacemos uso de 
las ventajas que nos proporciona un actor ya que no enviamos el siguiente mensaje hasta que el servidor nos responde el anterior. Por lo tanto vamos a olvidarnos 
de esta opción y vamos a ver que otras posibilidades existen.

#### Abrumar al sabio

Para solucionar el problema que nos plantea el `sabio` vamos a enviarle un montón de mensajes al mismo tiempo empleando clientes asíncronos, de esta manera vamos a
crear una situación en la que muchos mensajes llegan al mismo tiempo al actor y este los va procesando de uno en uno. Para ello vamos a emplear la biblioteca de Java
Future la cual nos permite programar código que se ejecuta de forma asíncrona.

```java
private static void interactWithNpc(Gson jsonParser) throws IOException, InterruptedException, ExecutionException {
    // Parametros comunes a todas las llamadas
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("npc", "sabio");
    params.put("character_name", "tim");

    // Ejecutor de tareas asíncronas
    ExecutorService executor = Executors.newFixedThreadPool(10);
    // Lista de tareas asíncronas
    List<Future<HashMap<String, Object>>> futures = new ArrayList<>();

    // Bucle de creación y lanzamiento de tareas asíncronas
    for (int i = 1; i < 7; i++) {
      HashMap<String, Object> mapa = new HashMap<String, Object>();
      mapa.put("jsonrpc", "2.0");
      mapa.put("method", "interact");
      mapa.put("params", params);
      mapa.put("id", String.valueOf(i));

      Callable<HashMap<String, Object>> task = () -> {
        // Implementación de un cliente
        return respuesta;
      };

      futures.add(executor.submit(task));
    }

    // Muestra de resultados por pantalla
    for (Future<HashMap<String, Object>> future : futures) {
      printServerResult(future.get());
    }

    executor.shutdown();
  }
```

La función que tenemos arriba muestra como vamos a emplear los futuros para obtener la llave. Si nos fijamos bien hemos abandonado la estructura del ejemplo
anterior. Ahora ya no creamos un cliente y enviamos el mensaje mediante el mismo. Vamos a ver que novedades tenemos.

En primer lugar, como vamos a crear varios clientes, es buena práctica separar todo aquello que podamos reutilizar. En este caso los parámetros de la primitiva
son iguales para todos los clientes, por lo tanto es lo primero que vamos poner.

```java
HashMap<String, String> params = new HashMap<String, String>();
params.put("npc", "sabio");
params.put("character_name", "tim");
```

A continuación empezamos con el código de Java asíncrono, creando el ejecutor de las tareas asíncronas y una lista vacía para almacenarlas.

```java
ExecutorService executor = Executors.newFixedThreadPool(10);
List<Future<HashMap<String, Object>>> futures = new ArrayList<>();
```

Una vez tenemos el ejecutor de tareas solo falta crear y ejecutar los clientes. Esta labor consiste en repetir la siguiente secuencia un número finito de veces.
La secuencia es:
  1. Crear el objeto mensaje tal y como lo hemos hecho en la práctica anterior.
  2. Crear un objeto tarea el cual consiste en una función que ejecuta un cliente como los que ya hemos visto y devuelve el resultado de ese cliente.
  3. Lanzar los objetos tarea empleando el ejecutor y almacenarlos en la lista que hemos creado.

El primer paso es muy sencillo, dentro del bucle creamos un `HashMap` como los que creamos en la práctica anterior.

```java
HashMap<String, Object> mapa = new HashMap<String, Object>();
mapa.put("jsonrpc", "2.0");
mapa.put("method", "interact");
mapa.put("params", params);
mapa.put("id", String.valueOf(i));
```

Para el segundo paso hay que introducir algunos conceptos de Java que no habían aparecido hasta ahora.

```java
Callable<HashMap<String, Object>> task = () -> {
  // Implementación de un cliente
  return respuesta;
};
```

El primer concepto que hemos introducido es la interfaz `Callable`, mediante esta interfaz se represnta una tarea que devuelve un resultado, puede lanzar una
excepción e implementa un solo método `call` sin argumentos. Todo esto se traduce en una función que, en nuestro caso, implementa un cliente que se comunica
con el servidor y devuelve el resultado de dicha comunicación.

El segundo concepto introducido son las expresiones lambda (`() -> {}`), las cuales no son objeto de estudio ahora mismo pero que, en este caso en concreto, nos van a servir
para crear funciones anónimas, ahorrándonos código.

Por último, el tercer paso es añadir el resultado de la función del ejecutor `submit` a la lista.

```java
futures.add(executor.submit(task));
```

Para complementar todo el trabajo hecho en los puntos anteriores es importante visualizar los resultados de las tareas asíncronas que hemos lanzado.

```java
for (Future<HashMap<String, Object>> future : futures) {
  printServerResult(future.get());
}
```

#### Finalizando la práctica

Te habrás dado cuenta que en el código presentado antes hay un comentario que dice "Implementación de un cliente", sustituyendo a este comentario vamos a tener que
implementar un cliente como los empleados en la práctica anterior. Para ello hay que abrir una conexión con el servidor y mandar el mensaje que ya hemos construido
(`mapa`). No te olvides de cerrar el socket antes de devolver el resultado.

Si hemos construido el cliente como ya sabíamos veremos seis mensajes por pantalla. ¿Notas algo raro? ¿Qué razón puede haber para que esto suceda?

Para terminar del todo con la práctica, una vez conseguida la `llave`, nos aseguraremos que efectivamente nuestro personaje tiene el objeto en su inventario y saldremos
de la habitación del `sabio` para finalizar la práctica en la siguiente sala.

###### Tabla de primitivas

| Primitiva | Respuesta / Acción    | Parámetros           | Explicación parámetro                                            |
| --------- | --------------------- | -------------------- | ---------------------------------------------------------------- |
| interact  | interactúa con un NPC | npc / character_name | nombre del NPC / nombre del personaje con el que estamos jugando |
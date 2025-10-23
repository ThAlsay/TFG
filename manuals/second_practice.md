# Práctica 2.

| Documento: | Módulo-2: Actores y colas de mensaje                    |
| ---------- | ------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática |
| Libro:     | Enunciado 2: Actores y colas de mensaje.                |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                               |
| Fecha:     | sabado, 20 de septiembre de 2025                        |
| Versión:   | 0.1                                                     |

## Tabla de contenidos

<!-- TOC -->

- [Tabla de contenidos](#tabla-de-contenidos)
- [Introducción](#introducci%C3%B3n)
- [Actores en los sistemas distribuidos](#actores-en-los-sistemas-distribuidos)
- [Aplicación en el juego](#aplicaci%C3%B3n-en-el-juego)
- [Puesta en práctica](#puesta-en-pr%C3%A1ctica)

<!-- /TOC -->

## Introducción

Una vez vista la arquitectura que empleamos para jugar vamos a ver como funciona un poco más de cerca el juego.
Para ello vamos a ver como empleamos actores dentro del juego y profundizaremos en alguna de sus partes.

## Actores en los sistemas distribuidos

Como ya hemos visto en la teoría los actores son unidades de cómputo que representan una parte de la lógica de la aplicación.
Cada actor cuenta con una dirección para interactuar con él mediante llamadas a funciones, estas funciones mandan un mensaje asíncrono al actor
y este lo almacena en una cola de mensajes. De esta cola de mensajes el actor va procesando cada mensaje y manda el resultado del proceso de vuelta al
remitente si este lo había solicitado en el mensaje.

Hemos visto cuatro posibles modelos de actores. El juego al que estamos jugando está escrito en Elixir, por lo tanto estamos ante un modelo de procesos.
Es decir, cada vez que creamos un actor dentro del juego este levanta un nuevo proceso dentro del ámbito del programa y devuelve la dirección en la que el proceso
ha sido creado. Mediante esta dirección podemos enviar mensajes al actor e interactuar con él.

En el caso de Elixir podemos hacer que esta dirección se guarde en un almacén global de direcciones y cualquier programa de Elixir que forme parte de la red
puede acceder a este almacén y comunicarse de forma remota con otros programas. Esta es una de las formas que tiene Elxir de facilitar la programación
de sistemas distribuidos.

## Aplicación en el juego

Ya sabemos que estamos utilizando actores para que el juego funcione como un sistema distribuido y que este está escrito en Elixir, ahora vamos a ver como
empleamos los actores exactamente. El juego está compuesto por varias entidades, cada entidad representa un elemento del juego. Una habitación, un objeto
o nuestro propio personaje son ejemplos de entidades que conforman el juego. Estas entidades tienen un identificador único que empleamos para mandar los mensajes
(en la práctica anterior ya los empleamos como parámetros de la peticiones).

A parte de las entidades, existen partes del juego que no actúan como actores. Estas partes pueden incluir el acceso a la base de datos o la gestión de los
propios actores. De esto podemos deducir que, al decidirnos por una arquitectura distribuida que emplee actores, no todas la partes del sistema se van a regir por las
características de estos y podemos combinarlos con otros patrones de diseño arquitectónico de sistemas distribuidos.

## Puesta en práctica

Ahora vamos a poner en práctica lo visto en los apartados anteriores. Si hemos seguido la práctica anterior deberiamos estar en la habitación con el npc sabio.
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

El sabio no parace muy por la labor de colaborar, habrá que insistir más. Para ello vamos a dejarle varios mensajes en su cola de mensajes.
Como el sabio es un NPC, es decir, un actor dentro de nuestro juego, irá procesando los mensajes que le lleguen a la cola y devolviendo el resultado.

El objetivo de esta práctica es conseguir que el sabio no nos ignore. Para ello tenemos varias opciones. La primera y más obvia es meter
el envío de mensajes en un bucle for y listo, pero, aunque funciona, no hacemos uso de las ventajas que nos proporciona un actor. Por lo tanto vamos
a olvidarnos de esta opción y vamos a ver que otras posibilidades existen.

Si nos acordamos, en al práctica pasada mencionamos a Tom, vamos a hacer uso de él. Para poder usar a Tom hay inciarlo igual que iniciamos a Tim y
llevarlo al punto en el que nos encontramos, para ello podemos emplear la práctica anterior omitiendo la parte de recoger el objeto y equiparlo.
Una vez Tom y Tim estén juntos, adapta el cliente de interacción para que Tom también interactue con el sabio y lanza los programas
(uno para Tim y otro para Tom). Al lanzar los programas a la vez los mensajes que lanza cada uno de ellos llegan de manera casi simultánea. De esta
manera hacemos uso de la cola de mensajes de los actores para acelerar un poco lo que tardamos en convencer al sabio para que no nos ignore.

Si queremos hacer lo mismo pero de forma avanzada podemos ignorar a Tom y hacer uso de la biblioteca de Java Future. Haciendo uso de esta biblioteca
podemos "duplicar" a Tim, es decir podemos mandar de manera totalmente simultánea los mensajes suficientes para que el sabio no nos ignore. Este es un
tópico avanzado pero que investigando lo suficiente no lleva más que unas líneas de código. PISTA: Lo que hay que ejecutar en cada función asíncrona es
un cliente de Java, no mandar un mensaje.

Una vez el sabio nos ha dejado de ignorar vuelve a la habitación anterior.

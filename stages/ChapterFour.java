package stages;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/*
 * Capitulo dedicado al aprendizaje sobre los actores en un sistema distribuido y 
 * a las colas de mensajes dentro de estos.
 */
public class ChapterFour {
  public static void main(String[] args) throws IOException, InterruptedException, ExecutionException {
    Gson jsonParser = new Gson();

    travel(jsonParser);
    inspectLocation(jsonParser);
    interactWithNpc(jsonParser);
    travel(jsonParser);
    inspectLocation(jsonParser);
    getCharacterStatus(jsonParser);
  }

  /*
   * Funcion pensada para mostrar las colas de mensajes mandando x peticiones a la
   * vez al mismo enpoint del servidor. Este endpoint transmite todos los mensajes
   * al mismo actor que los procesa de a uno y devuelve el resultado.
   * 
   * Se emplea los futuros de Java para las peticiones asincronas.
   */
  private static void interactWithNpc(Gson jsonParser) throws IOException, InterruptedException, ExecutionException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("npc", "sabio");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "interact");
    mapa.put("params", params);
    mapa.put("id", "1");

    ExecutorService executor = Executors.newFixedThreadPool(20);
    List<Future<String>> futures = new ArrayList<>();

    for (int i = 0; i < 11; i++) {
      Callable<String> task = () -> {
        Socket socket = new Socket("localhost", 3000);

        PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        out.println(jsonParser.toJson(mapa));

        HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(),
            new TypeToken<HashMap<String, Object>>() {
            }.getType());

        socket.close();
        return respuesta.toString();
      };

      futures.add(executor.submit(task));
    }

    for (Future<String> future : futures) {
      System.out.println(future.get());
    }

    executor.shutdown();
  }

  /*
   * Misma funcion del capitulo 1. Muestar el estado del personaje.
   */
  private static void getCharacterStatus(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_character");
    mapa.put("id", "2");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  /*
   * Misma funcion que en el capitulo 1. Muestra el estado de la instancia en la
   * que se encuentra el personaje.
   */
  private static void inspectLocation(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_current_location");
    mapa.put("id", "3");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  /*
   * Misma funcion que en el capitulo 2. Cambia al personaje de instancia.
   */
  private static void travel(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> params = new HashMap<String, String>();
    params.put("connection", "corredor_cueva_2");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "cross_connection");
    mapa.put("params", params);
    mapa.put("id", "4");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  /*
   * Funcion auxiliar para imprimir el resultado del servidor
   */
  private static void printServerResult(HashMap<String, Object> mapa) {
    Object resultado = mapa.get("result");
    Object error = mapa.get("error");

    if (resultado == null) {
      if (error == null) {
        System.out.println("Algo salio mal en el servidor");
      } else {
        System.out.println("Error al realizar la accion: " + error);
      }
    } else {
      System.out.println("Resultado de la accion: " + resultado);
    }
  }
}

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
import java.util.stream.Collectors;

/*
 * Solución de la segunda práctica
 */
public class SolucionPractica2 {
  public static void main(String[] args) throws IOException, InterruptedException, ExecutionException {
    Gson jsonParser = new Gson();

    Socket socket = new Socket("localhost", 3000);
    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    interactWithNpc(jsonParser);
    getCharacterStatus(jsonParser, out, in, "7");
    travel(jsonParser, out, in, "corredor_cueva_2", "8");
    inspectLocation(jsonParser, out, in, "9");

    socket.close();
  }

  private static void interactWithNpc(Gson jsonParser)
      throws IOException, InterruptedException, ExecutionException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("npc", "sabio");
    params.put("character_name", "tim");

    ExecutorService executor = Executors.newFixedThreadPool(20);
    List<Future<HashMap<String, Object>>> futures = new ArrayList<>();

    for (int i = 1; i < 7; i++) {
      HashMap<String, Object> mapa = new HashMap<String, Object>();
      mapa.put("jsonrpc", "2.0");
      mapa.put("method", "interact");
      mapa.put("params", params);
      mapa.put("id", String.valueOf(i));

      Callable<HashMap<String, Object>> task = () -> {
        Socket socket = new Socket("localhost", 3000);

        PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        out.println(jsonParser.toJson(mapa));

        HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(),
            new TypeToken<HashMap<String, Object>>() {
            }.getType());

        socket.close();
        return respuesta;
      };

      futures.add(executor.submit(task));
    }

    for (Future<HashMap<String, Object>> future : futures) {
      printServerResult(future.get());
    }

    executor.shutdown();
  }

  private static void inspectLocation(Gson jsonParser, PrintWriter out, BufferedReader in, String id)
      throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_current_location");
    mapa.put("params", params);
    mapa.put("id", id);

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
  }

  private static void travel(Gson jsonParser, PrintWriter out, BufferedReader in, String connection_value, String id)
      throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("connection", connection_value);
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "cross_connection");
    mapa.put("params", params);
    mapa.put("id", id);

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
  }

  private static void getCharacterStatus(Gson jsonParser, PrintWriter out, BufferedReader in, String id)
      throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_character");
    mapa.put("params", params);
    mapa.put("id", id);

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
  }

  /*
   * Funcion auxiliar para imprimir el resultado del servidor
   */
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

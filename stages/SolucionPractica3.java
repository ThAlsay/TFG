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
 * Solución de la tercera práctica
 */
public class SolucionPractica3 {
  public static void main(String[] args) throws IOException, InterruptedException, ExecutionException {
    Gson jsonParser = new Gson();

    Socket socket = new Socket("localhost", 3000);
    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    travel(jsonParser, out, in, "corredor_cueva_1", "1");
    attack(jsonParser, out, in, "2");
    getCharacterStatus(jsonParser, out, in, "3");

    socket.close();
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

  private static void attack(Gson jsonParser, PrintWriter out, BufferedReader in, String id) throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("enemy", "goblin");
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "attack");
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

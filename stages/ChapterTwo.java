package stages;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.HashMap;

/*
 * Escenario de muestra para demostrar como se interactua con el juego mediante peticiones con parametros.
 */
public class ChapterTwo {
  public static void main(String[] args) throws IOException {
    Gson jsonParser = new Gson();

    inspectLocation(jsonParser);
    travel(jsonParser);
    inspectLocation(jsonParser);
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
    mapa.put("id", "1");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  /*
   * Funcion que demuestra la construccion de una peticion al servidor incluyendo
   * parametros.
   * 
   * La peticion al servidor permite al personaje moverse de estancia por una
   * conexion que se pasa como parametro.
   */
  private static void travel(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> params = new HashMap<String, String>();
    params.put("connection", "entrada_cueva");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "cross_connection");
    mapa.put("params", params);
    mapa.put("id", "2");

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

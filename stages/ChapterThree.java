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
 * Escenario en el que se hace uso de lo que se muestra en el capitulo 2 para que el alumno practique las 
 * peticiones al servidor con parametros.
 * 
 * Teniendo los ejemplos anteriores y dando los endpoints a los que se tiene que apuntar el alumno tiene 
 * que ser capaz de completar las funciones pickObject y equipObject.
 */
public class ChapterThree {
  public static void main(String[] args) throws IOException {
    Gson jsonParser = new Gson();

    inspectLocation(jsonParser);
    pickObject(jsonParser);
    inspectLocation(jsonParser);
    getCharacterStatus(jsonParser);
    equipObject(jsonParser);
    getCharacterStatus(jsonParser);
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
   * Funcion en la que se le indica al servidor que el personaje quiere recoger el
   * objeto pasado por parametro
   */
  private static void pickObject(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> params = new HashMap<String, String>();
    params.put("object", "espada");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "take_object");
    mapa.put("params", params);
    mapa.put("id", "2");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  /*
   * Funcion en la que se indica al servidor que el personaje se quiere equipar un
   * objeto de su inventario.
   */
  private static void equipObject(Gson jsonParser) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> params = new HashMap<String, String>();
    params.put("object", "espada");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "equip_object");
    mapa.put("params", params);
    mapa.put("id", "3");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
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

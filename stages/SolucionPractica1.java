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
 * Solución de la primera práctica
 */
public class SolucionPractica1 {
  public static void main(String[] args) throws IOException {
    Gson jsonParser = new Gson();

    Socket socket = new Socket("localhost", 3000);
    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    inspectLocation(jsonParser, out, in, "1");
    travel(jsonParser, out, in, "entrada_cueva", "2");
    inspectLocation(jsonParser, out, in, "3");
    pickObject(jsonParser, out, in, "4");
    inspectLocation(jsonParser, out, in, "5");
    getCharacterStatus(jsonParser, out, in, "6");
    equipObject(jsonParser, out, in, "7");
    getCharacterStatus(jsonParser, out, in, "8");
    travel(jsonParser, out, in, "corredor_cueva_2", "9");
    inspectLocation(jsonParser, out, in, "10");

    socket.close();
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

  private static void pickObject(Gson jsonParser, PrintWriter out, BufferedReader in, String id) throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("object", "espada");
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "take_object");
    mapa.put("params", params);
    mapa.put("id", id);

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
  }

  private static void equipObject(Gson jsonParser, PrintWriter out, BufferedReader in, String id) throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("object", "espada");
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "equip_object");
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

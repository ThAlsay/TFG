package stages;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.HashMap;
import java.util.Scanner;

public class Ejemplo {
  private static String locationMessage = "{\n'jsonrpc': '2.0',\n'method': 'inspect_current_location',\n'params': {'character_name': 'tim'},\n'id': '1'\n}\n";
  private static String characterMessage = "{\n'jsonrpc': '2.0',\n'method': 'inspect_character',\n'params': {'character_name': 'tim'},\n"
      + "'id': '2'\n}\n";

  public static void main(String[] args) throws IOException {
    Gson jsonParser = new Gson();
    Scanner input = new Scanner(System.in);
    Socket socket = new Socket("localhost", 3000);
    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    System.out.println("Mensaje enviado al servidor");
    System.out.println(locationMessage);
    getCurrentLocation(jsonParser, out, in);

    System.out.println("Para continuar presiona enter");
    input.nextLine();

    System.out.println("Mensaje enviado al servidor");
    System.out.println(characterMessage);
    getCharacterStatus(jsonParser, out, in);

    socket.close();
  }

  /*
   * Mensaje al servidor la cual devuelve el estado
   * de la localizacion actual del personaje.
   */
  private static void getCurrentLocation(Gson jsonParser, PrintWriter out, BufferedReader in) throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_current_location");
    mapa.put("params", params);
    mapa.put("id", "1");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
  }

  /*
   * Llamada al servidor la cual devuelve el estado del propio personaje.
   */
  private static void getCharacterStatus(Gson jsonParser, PrintWriter out, BufferedReader in) throws IOException {
    HashMap<String, String> params = new HashMap<String, String>();
    params.put("character_name", "tim");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "inspect_character");
    mapa.put("params", params);
    mapa.put("id", "2");

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
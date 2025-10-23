package stages;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.HashMap;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class Utilities {
  public static void main(String[] args) throws IOException {
    if (args.length != 2) {
      System.out
          .println("Es necesario indicar el tipo de accion ('save' para guardar, 'login' para iniciar el personaje)");
    } else {
      Gson jsonParser = new Gson();

      switch (args[0]) {
        case "login":
          if (args[1].equals("tim")) {
            login(jsonParser, "distribuidos1");
          } else if (args[1].equals("tom")) {
            login(jsonParser, "distribuidos2");
          } else {
            System.out.println("El personaje seleccionado no existe");
          }
          break;

        case "save":
          if (args[1].equals("tim")) {
            saveGame(jsonParser, "distribuidos1");
          } else if (args[1].equals("tom")) {
            saveGame(jsonParser, "distribuidos2");
          } else {
            System.out.println("El personaje seleccionado no existe");
          }
          break;

        default:
          System.out
              .println("La accion seleccionada no es valida ('save' para guardar, 'login' para iniciar el personaje)");
          break;
      }
    }
  }

  private static void login(Gson jsonParser, String username) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> credentials = new HashMap<String, String>();

    credentials.put("username", username);
    credentials.put("password", "1234");

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "login");
    mapa.put("params", credentials);
    mapa.put("id", "1");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

  private static void saveGame(Gson jsonParser, String username) throws IOException {
    Socket socket = new Socket("localhost", 3000);

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    HashMap<String, String> params = new HashMap<String, String>();
    params.put("username", username);

    HashMap<String, Object> mapa = new HashMap<String, Object>();
    mapa.put("jsonrpc", "2.0");
    mapa.put("method", "save");
    mapa.put("params", params);
    mapa.put("id", "1");

    out.println(jsonParser.toJson(mapa));

    HashMap<String, Object> respuesta = jsonParser.fromJson(in.readLine(), new TypeToken<HashMap<String, Object>>() {
    }.getType());

    printServerResult(respuesta);
    socket.close();
  }

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

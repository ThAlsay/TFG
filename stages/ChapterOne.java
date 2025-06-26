package stages;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class ChapterOne {
  public static void main(String[] args) throws IOException {
    Socket socket = new Socket("localhost", 3000);
    System.out.println("Connection established");

    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

    out.println("{\"jsonrpc\": \"2.0\", \"method\": \"start\", \"id\": 1}");

    String response = in.readLine();
    System.out.println("Server says: " + response);

    socket.close();
  }
}
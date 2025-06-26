defmodule Game.TcpServer do
  use GenServer
  require Logger

  @port String.to_integer(System.get_env("PORT_JSON") || "3000")

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    case :gen_tcp.listen(@port, [:binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("TCP server listening on port #{@port}")

        Task.start(fn -> accept_loop(socket) end)
        {:ok, %{socket: socket}}

      {:error, reason} ->
        Logger.error("Failed to start TCP server: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  defp accept_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Client connected")
    Task.start(fn -> handle_client(client) end)
    accept_loop(socket)
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        Logger.debug("Received: #{inspect(data)}")

        case Jason.decode(data) do
          {:ok, term} ->
            case Game.RpcHandler.handle_rpc_request(term) do
              {:ok, response} ->
                :gen_tcp.send(socket, Jason.encode!(response) <> "\n")

              {:error, error} ->
                :gen_tcp.send(socket, Jason.encode!(error) <> "\n")
            end

          {:error, _error} ->
            :gen_tcp.send(
              socket,
              Jason.encode!(%{
                "jsonrcp" => "2.0",
                "error" => %{"code" => -32700, "message" => "Server JSON parsing error"},
                "id" => nil
              }) <> "\n"
            )
        end

      {:error, reason} ->
        Logger.error("Recv error: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end
end

defmodule Game.Application do
  require Logger
  use Application

  @port String.to_integer(System.get_env("PORT_JSON") || "3000")
  @nodes ["node1@enemies_node", "node2@character_node"]

  @impl true
  def start(_type, _args) do
    children = [
      Game.Supervisor,
      {ThousandIsland, port: @port, handler_module: Game.RpcHandler}
    ]

    opts = [strategy: :one_for_one, name: Game]
    res = Supervisor.start_link(children, opts)
    connect_nodes_with_retry(@nodes)
    Logger.info("Connected nodes: #{inspect(Node.list())}")
    Game.start()
    res
  end

  defp connect_nodes_with_retry(nodes) do
    Enum.each(nodes, fn node_str ->
      node = String.to_atom(node_str)
      connect_node(node, 5)
    end)
  end

  defp connect_node(_node, 0), do: :error

  defp connect_node(node, attempts_left) do
    case Node.connect(node) do
      true ->
        :ok

      false ->
        Logger.warning("#{node} could not be connected, retrying...")
        :timer.sleep(1000)
        connect_node(node, attempts_left - 1)
    end
  end
end

defmodule Game.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Game.Supervisor,
      Game.TcpServer
    ]

    opts = [strategy: :one_for_one, name: Game]
    Supervisor.start_link(children, opts)
  end
end

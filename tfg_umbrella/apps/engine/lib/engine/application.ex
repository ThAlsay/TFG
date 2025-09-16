defmodule Engine.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Engine.Repo,
      {Engine.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Engine]
    Supervisor.start_link(children, opts)
  end
end

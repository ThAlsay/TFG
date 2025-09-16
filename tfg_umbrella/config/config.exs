import Config

config :engine, Engine.Repo,
  database: "gamedb",
  username: "admin",
  password: "1234",
  hostname: if(Mix.env() == :prod, do: "database", else: "localhost")

config :engine, ecto_repos: [Engine.Repo]

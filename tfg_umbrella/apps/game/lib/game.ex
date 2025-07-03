defmodule Game do
  require Logger

  def start() do
    Engine.Builder.init_game("prueba", :main_supervisor)
    Logger.info("Game started")
  end
end

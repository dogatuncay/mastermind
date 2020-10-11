defmodule Mix.Tasks.RunConsoleGame do
  use Mix.Task

  @shortdoc "Runs the single player game"
  def run(_) do
    Mastermind.UserInterface.play()
  end
end

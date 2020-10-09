defmodule Mix.Tasks.RunGame do
  use Mix.Task

  @shortdoc "Runs the game"
  def run(_) do
    Mastermind.UserInterface.play()
  end
end

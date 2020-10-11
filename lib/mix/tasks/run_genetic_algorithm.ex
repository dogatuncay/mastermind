defmodule Mix.Tasks.RunGeneticAlgorithm do
  use Mix.Task

  @shortdoc "Runs the game"
  def run(_) do
    GeneticAlgorithm.Solver.play()
  end
end

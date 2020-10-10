defmodule GeneticAlgorithm.Solver do
  def color_length(), do: 6
  def genome_length(), do: 4

  def generate_genome(l) do
    Enum.map(1..l, fn _ -> Enum.random([0,1]) end)
  end

  def generate_population(l, generate_genome) do
    Enum.map(1..l, &(generate_genome(&1)))
  end
  def permute(genome, permutation_probability) do
    Enum.reduce(0..(genome_length()-1), genome, fn _, new_genome ->
      if :rand.uniform() < permutation_probability do
        random_position_1 = Enum.random(0..genome_length())
        random_position_2 = Enum.random(0..genome_length())
        updated_genome = List.replace_at(new_genome, random_position_1, Enum.at(new_genome, random_position_2))
        List.replace_at(updated_genome, random_position_2, Enum.at(new_genome, random_position_1))
      else
        new_genome
      end
    end)
  end
  def crossover_function(genome_a, genome_b, crossover_probability) do
    Enum.reduce(0..(genome_length()-1), [], fn index, new_code ->
      if :rand.uniform() > crossover_probability do
        [Enum.at(genome_a, index)|new_code]
      else
        [Enum.at(genome_b, index)|new_code]
      end
    end)
  end

  def mutate_single_gene(genome) do
    List.update_at(genome, Enum.random(0..genome_length()), fn _ -> Enum.random(0..color_length()) end)
  end

end

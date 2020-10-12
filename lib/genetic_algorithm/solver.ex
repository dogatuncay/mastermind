defmodule GeneticAlgorithm.Solver do
  alias Mastermind.Game
  def color_length(), do: 6
  def genome_length(), do: 4

  def crossover_probability(), do: 0.5
  def mutation_probability(), do: 0.03
  def permutation_probability(), do: 0.03

  def max_population_size(), do: 60
  def max_generations(), do: 100

  def generate_random_color() do
    Enum.random(1..color_length())
  end

  def generate_random_genome_index() do
    Enum.random(0..genome_length()-1)
  end

  def generate_random_genome() do
    Enum.map(1..genome_length(), fn _ -> generate_random_color() end)
  end

  def generate_population(pop_size) do
    Enum.map(1..pop_size, fn _ -> generate_random_genome() end)
  end

  def permute(genome) do
    Enum.reduce(0..(genome_length()-1), genome, fn _, new_genome ->
      if :rand.uniform() < permutation_probability() do
        random_position_1 = generate_random_genome_index()
        random_position_2 = generate_random_genome_index()
        updated_genome = List.replace_at(new_genome, random_position_1, Enum.at(new_genome, random_position_2))
        List.replace_at(updated_genome, random_position_2, Enum.at(new_genome, random_position_1))
      else
        new_genome
      end
    end)
  end

  def crossover(genome_a, genome_b) do
    Enum.map(0..(genome_length()-1), fn index ->
      genome = if :rand.uniform() > crossover_probability(), do: genome_a, else: genome_b
      Enum.at(genome, index)
    end)
  end

  def mutate(genome) do
    List.update_at(genome, generate_random_genome_index(), fn _ -> generate_random_color() end)
  end

  def count_same_color_guesses(guess, sequence) do
    length(guess) - length(sequence -- guess)
  end
  def count_correct_guesses(guess, sequence) do
    Enum.zip(guess, sequence)
    |> Enum.count(fn {a, b} -> a == b end)
  end
  def check_play(trial, guess) do
    correct_guesses = count_correct_guesses(trial, guess)
    {correct_guesses, count_same_color_guesses(trial, guess) - correct_guesses}
  end

  def get_difference(trial, {guess, {correct_guesses, same_color_guesses}}) do
    {correct_trials, same_color_trials} = check_play(trial, guess)
    {abs(correct_trials - correct_guesses), abs(same_color_trials - same_color_guesses)}
  end

  def fitness_score(trial, guesses) do
    guesses
    |> Enum.map(&get_difference(trial, &1))
    |> Enum.map(fn {correct, same_color} -> correct + same_color end)
    |> Enum.sum()
  end

  def generate_offsprings(population) do
    Enum.chunk_every(population, 2, 1, :discard)
    |> Enum.map(fn [mother, father] ->
      offspring = crossover(mother, father)
      mutated_offspring = if :rand.uniform() <= mutation_probability(), do: mutate(offspring), else: offspring
      permute(mutated_offspring)
    end)
  end

  def population_score(offsprings, guesses) do
    Enum.map(offsprings, fn offspring ->
      {fitness_score(offspring, guesses), offspring}
    end)
  end

  def get_chosen_with_elites(eligibles, chosen_ones, pop_size) do
    eligibles_to_add = min(pop_size - length(chosen_ones), length(eligibles))
    new_eligibles = Enum.take(eligibles, eligibles_to_add)
    new_chosen_ones = Enum.dedup(chosen_ones ++ new_eligibles)
    Enum.take(new_chosen_ones, pop_size)
  end

  def fill_population(population, pop_size) do
    genomes_to_generate = max(pop_size - length(population), 0)
    new_random_genomes = Enum.map(1..genomes_to_generate, fn _ -> generate_random_genome() end)
    population ++ new_random_genomes
  end

  # TODO: this loop is questionable
  def generation_inner_loop(population, pop_size, max_generations, guesses, chosen_ones, h) do
    if length(chosen_ones) <= pop_size and h <= max_generations do
      eligibles =
        generate_offsprings(population)
        |> population_score(guesses)
        |> Enum.sort_by(&elem(&1, 0))
        |> Enum.filter(fn {score, _} -> score == 0 end)

      if eligibles == [] do
        generation_inner_loop(population, pop_size, max_generations, guesses, chosen_ones, h+1)
      else
        new_eligibles = Enum.map(eligibles, fn {_, code} -> code end)
        chosen_w_elites = get_chosen_with_elites(new_eligibles, chosen_ones, pop_size)
        new_population = fill_population(chosen_w_elites, pop_size)
        generation_inner_loop(new_population, pop_size, max_generations, guesses, chosen_w_elites, h+1)
      end
    else
      chosen_ones
    end
  end

  def genetic_evolution(pop_size, generations, guesses) do
    population = generate_population(pop_size)
    generation_inner_loop(population, pop_size, generations, guesses, [], 1)
  end

  def get_more_eligibles(eligibles, guesses) when length(eligibles) == 0 do
    new_eligibles = genetic_evolution(max_population_size()*2, div(max_generations(), 2), guesses)
    get_more_eligibles(new_eligibles, guesses)
  end
  def get_more_eligibles(eligibles, _), do: eligibles


  def get_first_valid_eligible(eligibles, guess_codes) do
    Enum.find(eligibles, fn eligible -> eligible not in guess_codes end)
  end

  def play_loop(game, guesses) do
    cond do
      Game.won?(game) -> IO.puts("Genetic Algorithm guessed it right!")
      Game.is_game_over?(game) -> IO.puts("Genetic Algorithm, sorry, game is over!")
      true ->
        eligibles = genetic_evolution(max_population_size(), max_generations(), guesses)

        guess_codes = Enum.map(guesses, fn {code, _} -> code end)
        code = get_first_valid_eligible(eligibles, guess_codes)

        if code == nil do
          play_loop(game, guesses)
        else
          IO.puts "Genetic Algorithm guesses : #{inspect code}"
          new_game = Game.make_move(game, code)
          result = {new_game.correct_position, new_game.same_color}

          Game.print_score(new_game.same_color, "but in the wrong position")
          Game.print_score(new_game.correct_position, "and in the correct position")
          play_loop(new_game, [{code, result}|guesses])
        end
    end
  end

  def play() do
    game = Game.new

    IO.puts "Sequence we are guessing : #{inspect game.sequence}"
    first_guess = generate_random_genome()
    IO.puts "Genetic Algorithm guesses : #{inspect first_guess}"

    new_game = Game.make_move(game, first_guess)
    initial_result = {new_game.correct_position, new_game.same_color}
    guesses=[{first_guess, initial_result}]
    play_loop(new_game, guesses)
  end
end

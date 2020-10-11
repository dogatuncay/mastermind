defmodule GeneticAlgorithm.Solver do
  def color_length(), do: 6
  def genome_length(), do: 4

  def crossover_probability(), do: 0.5
  def mutation_probability(), do: 0.03
  def permutation_probability(), do: 0.03

  def population_size(), do: 60
  def max_generations(), do: 100

  def generate_genome() do
    Enum.map(1..genome_length(), fn _ -> Enum.random(1..color_length()) end)
  end

  def generate_population(population_size) do
    Enum.map(1..population_size, fn _ -> generate_genome() end)
  end

  def permute(genome) do
    Enum.reduce(0..(genome_length()-1), genome, fn _, new_genome ->
      if :rand.uniform() < permutation_probability() do
        random_position_1 = Enum.random(0..genome_length()-1)
        random_position_2 = Enum.random(0..genome_length()-1)
        updated_genome = List.replace_at(new_genome, random_position_1, Enum.at(new_genome, random_position_2))
        List.replace_at(updated_genome, random_position_2, Enum.at(new_genome, random_position_1))
      else
        new_genome
      end
    end)
  end
  def crossover(genome_a, genome_b) do
    Enum.reduce(0..(genome_length()-1), [], fn index, new_code ->
      if :rand.uniform() > crossover_probability() do
        [Enum.at(genome_a, index)|new_code]
      else
        [Enum.at(genome_b, index)|new_code]
      end
    end)
  end

  def mutate(genome) do
    List.update_at(genome, Enum.random(0..genome_length()), fn _ -> Enum.random(0..color_length()) end)
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

  def get_difference(trial, {guess, guess_result}) do
    trial_result = check_play(trial, guess)
    {abs(elem(trial_result,0) - elem(guess_result,0)), abs(elem(trial_result,1) - elem(guess_result,1))}
  end

  def fitness_score(trial, guesses) do
    differences = Enum.map(guesses, &get_difference(trial, &1))
    Enum.reduce(differences, 0, fn {correct_guesses, same_color_guesses}, score ->
      score + correct_guesses + same_color_guesses
    end)
  end
  def generate_offsprings(population) do
    Enum.reduce(0..(length(population)-2), [], fn i, offsprings ->
      mother = Enum.at(population, i)
      father = Enum.at(population, i+1)
      offspring = crossover(mother, father)
      mutated_offspring = if :rand.uniform() <= mutation_probability(), do: mutate(offspring), else: offspring
      [permute(mutated_offspring)|offsprings]
    end)
  end

  def population_score(offsprings, guesses) do
    Enum.reduce(offsprings, [], fn offspring, acc ->
      [{fitness_score(offspring, guesses), offspring}| acc]
    end)
  end

  def remove_duplicate(eligibles, chosen_list) do
    Enum.reduce(chosen_list, [], fn chosen, new_chosen_list ->
      if chosen in eligibles, do: [generate_genome()|new_chosen_list], else: [chosen|new_chosen_list]
    end)
  end

  def get_chosen_with_elites(eligibles, chosen_ones, population_size) do
    new_chosen_list = remove_duplicate(eligibles, chosen_ones)
    Enum.reduce(0..(population_size-length(chosen_ones)-1), new_chosen_list, fn index, chosen_w_elites ->
      if index < length(eligibles) do
        eligible = Enum.at(eligibles, index)
        if eligible not in chosen_w_elites do
          [eligible|chosen_w_elites]
        else
          chosen_w_elites
        end
      else
        chosen_w_elites
      end
    end)
  end

  def fill_population(population, population_size) do
    population ++ Enum.map(1..(population_size-length(population)), fn _ -> generate_genome() end)
  end

  def generation_inner_loop(population, population_size, generations, guesses, chosen_ones, h) do
      if length(chosen_ones) <= population_size and h <= generations do
        eligibles =
          generate_offsprings(population)
          |> population_score(guesses)
          |> Enum.sort_by(&elem(&1, 0))
          |> Enum.filter(fn {score, _} -> score == 0 end)

        case length(eligibles) do
          0 -> generation_inner_loop(population, population_size, generations, guesses, chosen_ones, h+1)
          _ ->
            new_eligibles = Enum.map(eligibles, fn {_, code} -> code end)
            chosen_w_elites = get_chosen_with_elites(new_eligibles, chosen_ones, population_size)
            new_population = fill_population(chosen_w_elites, population_size)
            generation_inner_loop(new_population, population_size, generations, guesses, chosen_w_elites, h+1)
        end
      else
        chosen_ones
    end
  end

  def genetic_evolution(population_size, generations, guesses) do
    population = generate_population(population_size)
    generation_inner_loop(population, population_size, generations, guesses, [], 1)
  end

  def get_more_eligibles(eligibles, guesses) when length(eligibles) == 0 do
    new_eligibles = genetic_evolution(population_size()*2, div(max_generations(), 2), guesses)
    get_more_eligibles(new_eligibles, guesses)
  end
  def get_more_eligibles(eligibles, _), do: eligibles


  def pop_eligibles([first_eligible|rest], guess_codes) do
    if first_eligible in guess_codes do
      pop_eligibles(rest, guess_codes)
    else
      first_eligible
    end
  end

  def play_loop(result, population_size, sequence, generations, guesses) when result != {4,0} do
    eligibles = genetic_evolution(population_size, generations, guesses)
    IO.puts "Eligibles #{inspect eligibles}"

    guess_codes = Enum.map(guesses, fn {code, _} -> code end)
    code = pop_eligibles(eligibles, guess_codes)
    result = check_play(code, sequence)
    if result == {4,0} do
      IO.puts("You won!")
      IO.puts "#{inspect code}, #{inspect result}"
    else
      play_loop(result, population_size, sequence, generations, [{code, result}|guesses])
    end
  end

  def play_loop(_, _, _, _, guesses) do
    guesses
  end

  def play() do
    sequence = generate_genome()
    IO.puts "Sequence we are guessing : #{inspect sequence}"
    first_guess = generate_genome()
    initial_result = check_play(first_guess, sequence)

    guesses=[{first_guess, initial_result}]
    play_loop(initial_result, population_size(), sequence, max_generations(), guesses)
  end
end

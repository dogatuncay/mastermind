defmodule Mastermind.Game do
  @enforce_keys [:sequence, :guesses, :same_color, :correct_position]
  defstruct @enforce_keys

  defp generate_sequence() do
    Enum.map(1..4, fn _ -> Enum.random(colors()) end)
  end

  defp count_same_color_guesses(guess, sequence) do
    length(guess) - length(sequence -- guess)
  end

  defp count_correct_guesses(guess, sequence) do
    Enum.zip(guess, sequence)
    |> Enum.count(fn {a, b} -> a == b end)
  end

  def color_mapping do
    %{"R" => 1, "G" => 2, "B" => 3, "Y" => 4, "O" => 5, "D" => 6}
  end

  def colors, do: 1..6

  def won?(%__MODULE__{sequence: sequence, correct_position: correct}) do
    length(sequence) == correct
  end

  def is_game_over?(state = %__MODULE__{guesses: guesses}) do
    won?(state) or guesses == 0
  end

  def print_score(number, suffix) do
    plural = if number > 1, do: "s were", else: " was"
    IO.puts "#{number} color#{plural} correct #{suffix}"
  end

  def new do
    %__MODULE__{
      sequence: generate_sequence(),
      guesses: 9,
      same_color: 0,
      correct_position: 0
    }
  end

  def make_move(game, guess) do
    same_color = count_same_color_guesses(guess, game.sequence)
    correct_position = count_correct_guesses(guess, game.sequence)
    %{ game |
      correct_position: correct_position,
      same_color: same_color - correct_position,
      guesses: game.guesses-1
    }
  end
end

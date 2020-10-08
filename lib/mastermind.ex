defmodule Mastermind do
  @moduledoc """
  Documentation for `Mastermind`.
  """

  @colors ["R", "G", "B", "Y", "O", "D"]

  def generate_sequence() do
    Enum.map(1..4, fn _ -> Enum.random(@colors) end)
  end

  def valid_guess?(guess, sequence) do
    length(guess) == length(sequence) and Enum.all?(guess, &Enum.member?(@colors, &1))
  end

  def collect_input() do
    IO.gets("Choose four colors of these colors: R, G, B, Y, O, D, for eg: RGBY\n")
    |> String.trim()
    |> String.upcase()
    |> String.codepoints()
  end

  def count_same_color_guesses(guess, sequence) do
    length(guess) - length(sequence -- guess)
  end

  def count_correct_guesses(guess, sequence) do
    Enum.zip(guess, sequence)
    |> Enum.count(fn {a, b} -> a == b end)
  end

  def print_score(number, suffix) do
    plural = if number > 1, do: "s were", else: " was"
    IO.puts "#{number} color#{plural} correct #{suffix}"
  end

  def game_loop(guesses, sequence) do
    if guesses > 0 do
      IO.puts "You have #{guesses} guesses left"
      guess = collect_input()
      if not valid_guess?(guess, sequence) do
        IO.puts "Input is not valid"
        game_loop(guesses, sequence)
      else
        same_color = count_same_color_guesses(guess, sequence)
        correct = count_correct_guesses(guess, sequence)
        print_score(same_color - correct, "but in the wrong position")
        print_score(correct, "and in the correct position")
        if correct == length(sequence) do
          IO.puts "You guessed it right"
        else
          game_loop(guesses-1, sequence)
        end
      end
    else
      IO.puts "You lost (boo)"
      IO.puts "The correct sequence was: #{Enum.join(sequence)}"
    end
  end

  def play do
    sequence = generate_sequence()
    game_loop(9, sequence)
  end
end

IO.inspect Mastermind.play()

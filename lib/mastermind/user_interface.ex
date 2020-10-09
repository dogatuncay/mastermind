defmodule Mastermind.UserInterface do
  alias Mastermind.Game

  def play do
    game = Game.new
    game_loop(game)
  end

  def valid_guess?(guess, sequence) do
    length(guess) == length(sequence) and Enum.all?(guess, &Enum.member?(Game.colors, &1))
  end

  def collect_move(sequence) do
    guess = get_input()
    if not valid_guess?(guess, sequence) do
      IO.puts "Input is not valid"
      collect_move(sequence)
    else
      guess
    end
  end

  def print_score(number, suffix) do
    plural = if number > 1, do: "s were", else: " was"
    IO.puts "#{number} color#{plural} correct #{suffix}"
  end

  def get_input() do
    IO.gets("Choose four colors of these colors: R, G, B, Y, O, D, for eg: RGBY\n")
    |> String.trim()
    |> String.upcase()
    |> String.codepoints()
  end

  def game_loop(game) do
    cond do
      Game.won?(game) -> IO.puts("You guess it right!")
      Game.is_game_over?(game) -> IO.puts("Sorry, game is over!")
      true ->
        new_game = Game.make_move(game, collect_move(game.sequence))
        print_score(new_game.same_color - new_game.correct_position, "but in the wrong position")
        print_score(new_game.correct_position, "and in the correct position")
        game_loop(new_game)
    end
  end


end

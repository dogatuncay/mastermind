# Mastermind

Mastermind game with two settings. You can play the game yourself via the console or have the genetic algorithm play it for you (guesses in average ~4 steps) and crush your self-confidence. 

Implementation based on [paper](https://lirias.kuleuven.be/bitstream/123456789/164803/1/kbi_0806.pdf)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mastermind` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mastermind, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mastermind](https://hexdocs.pm/mastermind).


## Running the Game

To play the game yourself from the console, run: 

  `mix run_console_game`

Feeling lazy? To have the genetic algorithm play the game for you, run:

  `mix run_genetic_algorithm`
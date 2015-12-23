defmodule Cards.Game do
  use GenServer

  @registered_name CardsGame

  def start_link do
    GenServer.start_link(__MODULE__, :no_args, [name: @registered_name])
  end

  # Client API

  def show_state do
    game_state = GenServer.call(CardsGame, :state)
    deck_state = GenServer.call(:deck, :state)

    IO.puts "Game State:"
    Cards.Round.show_state(:round)
    deck_cards = Cards.Deck.show_deck
    IO.write "     deck: "
    IO.inspect(deck_cards)
    IO.puts "     kobayakawa: #{Cards.Card.get_value(deck_state.kobayakawa)}"
    for player <- game_state.players do
      Cards.Player.show_private_state(player)
    end
  end

  def get_state do
    GenServer.call(CardsGame, :state)
  end

  # Server callbacks

  def init(:no_args) do
    {:ok, deck} = Cards.Deck.start_link
    players = for count <- 1..4 do 
      {:ok, player} = Cards.Player.start_link("player#{count}")
      Cards.Player.draw(player, 1)
      player
    end
    {:ok, round} = Cards.Round.start_link(deck, players)
    Cards.Round.begin_next_round(:round)
    {:ok, %{deck: deck, players: players, round: round}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

end

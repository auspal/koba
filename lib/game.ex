defmodule Cards.Game do
  use GenServer

  @registered_name CardsGame

  def start_link do
    GenServer.start_link(__MODULE__, :no_args, [name: @registered_name])
  end

  # Client API

  def show_state do
    IO.puts "\nGAME STATE:"

    # round state
    round_state = GenServer.call(:round, :state)
    IO.puts "          round: #{round_state.round}"
    IO.puts "     kamons bet: #{round_state.bet_kamons}"
    player_state = GenServer.call(round_state.current_player, :state)
    IO.puts " current player: #{player_state.name}"

    # deck state
    deck_cards = Cards.Deck.show_deck
    IO.write "           deck: "
    IO.inspect(deck_cards)
    deck_state = GenServer.call(:deck, :state)
    IO.puts "     kobayakawa: #{Cards.Card.get_value(deck_state.kobayakawa)}"

    # players state
    game_state = GenServer.call(CardsGame, :state)
    for player <- game_state.players do
      player_state = GenServer.call(player, :state)
      cards = GenServer.call(player, :show_hand)
      IO.puts "#{String.upcase(Atom.to_string(player_state.name))}:"
      IO.puts "    kamon: #{player_state.kamon}"
      IO.puts "kamon bet: #{player_state.kamon_bet}"
      IO.puts "     hand: #{Cards.Player.card_values(cards)}"
      IO.puts "  discard: #{Cards.Player.card_values(player_state.discard)}"
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
    {:ok, %{deck: deck, players: players, round: round}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

end

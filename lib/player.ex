defmodule Cards.Player do
  use GenServer

  def start_link(name) do
    name = String.to_atom(name)
    GenServer.start_link(__MODULE__, name, name: name)
    {:ok, name}
  end

  # Client API

  def show_public_state(player) do
    player_state = GenServer.call(player, :state)
    IO.puts "#{player_state.name}:"
    IO.puts "   koman: #{player_state.koman}"
    IO.puts " discard: #{card_values(player_state.discard)}"
  end

  def show_private_state(player) do
    player_state = GenServer.call(player, :state)
    cards = GenServer.call(player, :show_hand)
    IO.puts "#{player_state.name}:"
    IO.puts "   koman: #{player_state.koman}"
    IO.puts "    hand: #{card_values(cards)}"
    IO.puts " discard: #{card_values(player_state.discard)}"
  end

  def draw(player, count) do
    GenServer.call(player, {:draw, count})
  end

  def discard(player, card_name) do
    #card_name = String.to_atom(card_name)
    discard = GenServer.call(player, {:discard, card_name})
    finish_turn(player, :true)
    discard
  end
  
  def replace_kobayakawa(player) do
    Cards.Deck.replace_kobayakawa(:deck)
    finish_turn(player, :true)
  end

  def fight(player) do
    Cards.Round.bet_koman
    GenServer.call(player, :bet_koman)
    finish_turn(player, :true)
  end

  def pass(player) do
    finish_turn(player, :true)
  end

  defp finish_turn(player, true_false) do
    GenServer.call(player, {:finish_turn, true_false})
    Cards.Round.next_turn
  end

  def get_state(player) do
    GenServer.call(player, :state)
  end

  def show_hand(player) do
    GenServer.call(player, :show_hand)
  end

  # Server callbacks

  def init(name) do
    {:ok, %{name: name, koman: 4, hand: [], discard: nil, turn_finished: :false}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:show_hand, _, state) do
    {:reply, state.hand, state}
  end

  def handle_call({:draw, count}, _, state) do
    cards = Cards.Deck.draw(:deck, count) 
    {:reply, cards, %{state | hand: cards ++ state.hand}}
  end

  def handle_call({:discard, card_name}, _, state) do
    discard = Enum.find(state.hand, fn card -> card == card_name end)
    new_hand = Enum.filter(state.hand, fn(card) -> discard != card end)
    {:reply, discard, %{state | hand: new_hand, discard: discard}}
  end

  def handle_call(:bet_koman, _, state) do
    {:reply, :ok, %{state | koman: state.koman-1}}
  end

  def handle_call({:finish_turn, true_false}, _, state) do
    {:reply, true_false, %{state | turn_finished: true_false}}
  end

  defp card_values(nil), do: ""
  defp card_values(card) when is_atom(card) do 
    Cards.Card.get_value(card)
  end
  defp card_values(cards) when is_list(cards) do
    Enum.map(cards, fn card -> Cards.Card.get_value(card) end)
    |> Enum.join(",")
  end
  defp card_values(card) when is_pid(card) do
    Cards.Card.get_value(card) |> Integer.to_string
  end

end

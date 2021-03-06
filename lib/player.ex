defmodule Koba.Player do
  use GenServer

  def start_link(name) do
    name = String.to_atom(name)
    GenServer.start_link(__MODULE__, name, name: name)
    {:ok, name}
  end

  # Client API

  def draw(player, count) do
    GenServer.call(player, {:draw, count})
  end

  def discard(player, card_name) do
    discard = GenServer.call(player, {:discard, card_name})
    finish_turn(player, :true)
    discard
  end
  
  def replace_kobayakawa(player) do
    Koba.Deck.replace_kobayakawa(:deck)
    finish_turn(player, :true)
  end

  def fight(player) do
    Koba.Round.bet_kamon
    GenServer.call(player, :bet_kamon)
    finish_turn(player, :true)
  end

  def pass(player) do
    finish_turn(player, :true)
  end

  defp finish_turn(player, true_false) do
    GenServer.call(player, {:finish_turn, true_false})
    Koba.Round.next_turn
  end

  def take_kamons(player, kamon_count) do
    GenServer.call(player, {:take_kamons, kamon_count})
  end

  def reset_for_round(player) do
    GenServer.call(player, :reset_for_round)
  end

  def get_state(player) do
    GenServer.call(player, :state)
  end

  def show_hand(player) do
    GenServer.call(player, :show_hand)
  end

  # Server callbacks

  def init(name) do
    {:ok, %{name: name, kamon: 4, kamon_bet: 0, hand: [], discard: nil, turn_finished: :false}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:show_hand, _, state) do
    {:reply, state.hand, state}
  end

  def handle_call({:draw, count}, _, state) do
    cards = Koba.Deck.draw(:deck, count) 
    {:reply, cards, %{state | hand: cards ++ state.hand}}
  end

  def handle_call({:discard, card_name}, _, state) do
    discard = Enum.find(state.hand, fn card -> card == card_name end)
    new_hand = Enum.filter(state.hand, fn(card) -> discard != card end)
    {:reply, discard, %{state | hand: new_hand, discard: discard}}
  end

  def handle_call(:bet_kamon, _, state) do
    {:reply, :ok, %{state | kamon: state.kamon-1, kamon_bet: state.kamon_bet+1}}
  end

  def handle_call({:take_kamons, count}, _, state) do
    new_kamon_count = count + state.kamon
    {:reply, new_kamon_count, %{state | kamon: new_kamon_count}}
  end

  def handle_call({:finish_turn, true_false}, _, state) do
    {:reply, true_false, %{state | turn_finished: true_false}}
  end

  def handle_call(:reset_for_round, _, state) do
    {:reply, :ok, %{state | kamon_bet: 0, hand: [], discard: nil, turn_finished: :false}}
  end

  def card_values(nil), do: ""
  def card_values(card) when is_atom(card) do 
    Koba.Card.get_value(card)
  end
  def card_values(cards) when is_list(cards) do
    Enum.map(cards, fn card -> Koba.Card.get_value(card) end)
    |> Enum.join(",")
  end
  def card_values(card) when is_pid(card) do
    Koba.Card.get_value(card) |> Integer.to_string
  end

end

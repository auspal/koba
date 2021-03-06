defmodule Koba.Deck do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :no_args, name: :deck)
  end

  # Client API

  def draw(deck, count) do
    GenServer.call(deck, {:draw, count})
  end

  def replace_kobayakawa(deck) do
    GenServer.call(deck, :replace_kobayakawa)
  end

  def show_deck do
    GenServer.call(:deck, :show)
  end

  def show_kobayakawa do
    GenServer.call(:deck, :show_kobayakawa)
  end

  def reset_for_round do
    GenServer.call(:deck, :reset_for_round)
  end

  def get_state(deck) do
    GenServer.call(deck, :state)
  end

  # Server callbacks

  def init(:no_args) do
    cards = for value <- 1..15, into: [] do
      {:ok, card} = Koba.Card.start_link(value)
      card
    end
    #:random.seed(:os.timestamp) # removed to provide consistent test values
    [kobayakawa | remaining] = Enum.shuffle(cards)
    {:ok, %{kobayakawa: kobayakawa, cards: remaining}}
  end

  def handle_call(:show, _, deck) do
    {:reply, card_values(deck.cards), deck}
  end

  def handle_call(:show_kobayakawa, _, deck) do
    {:reply, deck.kobayakawa, deck}
  end

  def handle_call({:draw, count}, _, deck) do
    {dealt, remaining} = Enum.split(deck.cards, count)
    {:reply, dealt, %{deck | cards: remaining}}
  end

  def handle_call(:replace_kobayakawa, _, deck) do
    [kobayakawa | remaining] = deck.cards
    {:reply, kobayakawa, %{deck | kobayakawa: kobayakawa, cards: remaining}}
  end

  def handle_call(:reset_for_round, _, deck) do
    cards = for value <- 1..15, into: [] do
      String.to_atom("card#{value}")
    end
    [kobayakawa | remaining] = Enum.shuffle(cards)
    {:reply, :ok, %{kobayakawa: kobayakawa, cards: remaining}}
  end

  def handle_call(:state, _, deck) do
    {:reply, deck, deck}
  end

  defp card_values(deck) do
    Enum.map(deck, fn card -> Koba.Card.get_value(card) end)
  end

end

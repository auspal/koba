defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "all players draw and discard" do
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 10
  end
end

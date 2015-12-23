defmodule CardsTest do
  use ExUnit.Case, async: false
  doctest Cards

  ExUnit.configure exclude: :pending

  @tag :pending
  test "personal testing" do
    Enum.each(1..20, fn(x) -> IO.puts draw_or_replace end)
  end
  
  test "game is configured" do
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 10
    perform_round
    Cards.Game.show_state
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 6
  end

  def perform_round do
    game_state = Cards.Game.get_state
    Enum.each(game_state.players, &perform_draw_phase(&1))
    Enum.each(game_state.players, &perform_fight_phase(&1))
  end

  def perform_draw_phase(player) do
    case draw_or_replace do
      :draw_and_discard -> 
        Cards.Player.draw(player, 1)
        player_state = Cards.Player.get_state(player)
        Cards.Player.discard(player, choose_one_card(player_state.hand))
      :replace_kobayakawa ->
        Cards.Player.replace_kobayakawa(player)
    end
  end

  def perform_fight_phase(player) do
    case fight_or_pass do
      :fight -> Cards.Player.fight(player)
      :pass -> Cards.Player.pass(player)
    end
  end

  defp draw_or_replace do
    [:draw_and_discard, :replace_kobayakawa]
    |> Enum.at((:random.uniform(2)-1))
  end

  defp choose_one_card(hand) do
    hand
    |> Enum.at(:random.uniform(2)-1)
  end

  defp fight_or_pass do
    [:fight, :pass]
    |> Enum.at((:random.uniform(2)-1))
  end

end

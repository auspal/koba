defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  ExUnit.configure exclude: :pending

  @tag :pending
  test "personal testing" do
    Enum.each(1..20, fn(x) -> IO.puts draw_phase_decision end)
  end
  
  test "game is configured" do
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 10
    perform_round
    #player_performs_draw_phase(:player1)
    Cards.Game.show_state
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 6
  end

  def perform_round do
    game_state = Cards.Game.get_state
    game_state.players
    |> Enum.each(&perform_draw_phase(&1))
  end

  def perform_draw_phase(player) do
    case draw_phase_decision do
      :draw_and_discard -> 
        Cards.Player.draw(player, 1)
        player_state = Cards.Player.get_state(player)
        hand = player_state.hand
        Cards.Player.discard(player, choose_one_card(hand))
      :replace_kobayakawa ->
        Cards.Player.replace_kobayakawa(player)
    end
  end

  def perform_fight_phase(player) do
    case fight_or_pass do
      :fight ->  Empty
    end
  end

  defp draw_phase_decision do
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

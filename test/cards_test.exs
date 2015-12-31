defmodule CardsTest do
  use ExUnit.Case, async: false
  doctest Cards

  ExUnit.configure exclude: :pending

  test "play game1" do
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 10

    perform_round
    Cards.Game.show_state
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 6

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

    Cards.Round.start_next_round
    perform_round
    Cards.Game.show_state

  end

  defp perform_round do
    game_state = Cards.Game.get_state
    Enum.each(game_state.players, &perform_draw_phase(&1))
    Enum.each(game_state.players, &perform_fight_phase(&1))
    Cards.Round.end_round
  end

  defp perform_draw_phase(player) do
    case draw_or_replace do
      :draw_and_discard -> 
        Cards.Player.draw(player, 1) 
        player_state = Cards.Player.get_state(player)
        Cards.Player.discard(player, choose_one_card(player_state.hand))
      :replace_kobayakawa ->
        Cards.Player.replace_kobayakawa(player)
    end
  end

  defp perform_fight_phase(player) do
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

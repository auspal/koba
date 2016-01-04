defmodule KobaTest do
  use ExUnit.Case, async: false
  doctest Koba

  ExUnit.configure exclude: :pending

  test "play game1" do
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 10

    perform_round
    Koba.Game.show_state
    deck_state = GenServer.call(:deck, :state)
    assert Enum.count(deck_state.cards) == 6

    perform_rounds(6)
  end

  defp perform_rounds(0) do
    IO.puts "\nGame Over..."
  end
  defp perform_rounds(x) do
    Koba.Round.start_next_round
    perform_round
    Koba.Game.show_state
    perform_rounds(x-1)
  end

  defp perform_round do
    game_state = Koba.Game.get_state
    Enum.each(game_state.players, &perform_draw_phase(&1))
    Enum.each(game_state.players, &perform_fight_phase(&1))
    Koba.Round.end_round
  end

  defp perform_draw_phase(player) do
    case draw_or_replace do
      :draw_and_discard -> 
        Koba.Player.draw(player, 1) 
        player_state = Koba.Player.get_state(player)
        Koba.Player.discard(player, choose_one_card(player_state.hand))
      :replace_kobayakawa ->
        Koba.Player.replace_kobayakawa(player)
    end
  end

  defp perform_fight_phase(player) do
    case fight_or_pass do
      :fight -> Koba.Player.fight(player)
      :pass -> Koba.Player.pass(player)
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

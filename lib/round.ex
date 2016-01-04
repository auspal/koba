defmodule Koba.Round do
  use GenServer
  
  @number_of_rounds 7
  @kamons_per_round [1,1,1,1,1,1,2]

  def start_link(deck, players) do
    GenServer.start_link(__MODULE__, {deck, players}, name: :round)
  end

  # Client API

  def bet_kamon do
    GenServer.call(:round, :bet_kamon)
  end

  def next_turn do
    GenServer.call(:round, :next_player)
  end

  def end_round do
    GenServer.call(:round, :end_round)
  end

  def start_next_round do
    GenServer.call(:round, :start_round)
  end

  # Server callbacks

  def init({deck, players}) do
    [first_player | remaining_players] = players
    {:ok, %{     round: 1, 
            bet_kamons: 0, 
                  deck: deck, 
               players: players, 
        current_player: first_player, 
     remaining_players: remaining_players}}
  end

  def handle_call(:next_player, _, state) do
    {next_player, remaining_players} = 
      case state.remaining_players do
        [] -> {:player1, []}
        _ -> [next_player | remaining_players]  = state.remaining_players
             {next_player, remaining_players}
      end
    {:reply, next_player, %{state | current_player: next_player, remaining_players: remaining_players}}
  end

  def handle_call(:end_round, _from, state) do
    # score each player left in round (who decided to fight)
    betting_players = Enum.filter(state.players, fn player -> player_state = Koba.Player.get_state(player)
                                            player_state.kamon_bet > 0 end)
    low_card_player = Enum.reduce(betting_players, nil, fn player, acc -> low_card_player(player, acc) end)
    round_winner = round_winner(player_totals(betting_players, low_card_player))
    kamons_won = state.bet_kamons + Enum.at(@kamons_per_round, state.round-1)
    Koba.Player.take_kamons(round_winner, kamons_won)
    {:reply, :ok, state}
  end

  def handle_call(:start_round, _, state) do
    Koba.Deck.reset_for_round
    Enum.each(state.players, fn player -> Koba.Player.reset_for_round(player) 
                                          Koba.Player.draw(player, 1) end)
    [first_player | remaining_players] = state.players
    {:reply, :ok, %{state | round: state.round+1, bet_kamons: 0, current_player: first_player, 
                            remaining_players: remaining_players}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:bet_kamon, _, state) do
    {:reply, :ok, %{state | bet_kamons: state.bet_kamons+1}}
  end

  defp player_totals(betting_players, low_card_player) do
    kobayakawa_value = Koba.Card.get_value(Koba.Deck.show_kobayakawa)
    Enum.reduce(betting_players, [], 
      fn player, acc -> player_score = case player do
                          low_card_player -> {player, card_value_of_player(player)+kobayakawa_value}
                           _ -> {player, card_value_of_player(player)}
                        end
                        [player_score | acc]
      end)
  end

  defp round_winner(player_totals) do
    {round_winner, _} = Enum.reduce(player_totals, nil, fn {player, total}, acc -> 
                                            case acc do
                                              nil -> {player, total}
                                              _ -> if total > elem(acc, 1) do 
                                                    {player, total}
                                                   else
                                                    acc
                                                   end
                                             end
    end)
    round_winner
  end

  defp card_value_of_player(player) do
    [player_card|_] = Koba.Player.show_hand(player)
    Koba.Card.get_value(player_card)
  end
  
  defp low_card_player(player, acc) do
    case acc do
      nil -> player
      _ -> if card_value_of_player(player) > card_value_of_player(acc) do 
                  player
               else
                 acc
               end
    end
  end

end

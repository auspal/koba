defmodule Cards.Round do
  use GenServer

  @number_of_rounds 7
  @kamons_per_round [1,1,1,1,1,1,2]

  def start_link(deck, players) do
    GenServer.start_link(__MODULE__, {deck, players}, name: :round)
  end

  # Client API

  def begin_next_round do
    GenServer.call(:round, :start_round)
    GenServer.call(:round, :next_player)
  end

  def show_state(server) do
    state = GenServer.call(server, :state)
    IO.puts "          round: #{state.round}"
    IO.puts "     kamons bet: #{state.bet_kamons}"
    player_state = GenServer.call(state.current_player, :state)
    IO.puts " current player: #{player_state.name}"
  end

  def bet_kamon do
    GenServer.call(:round, :bet_kamon)
  end

  def next_turn do
    GenServer.call(:round, :next_player)
  end

  def end_round do
    GenServer.call(:round, :end_round)
  end

  # Server callbacks

  def init({deck, players}) do
    [first_player | remaining_players] = players
    {:ok, %{round: 1, bet_kamons: 0, deck: deck, players: players, current_player: first_player, remaining_players: players}}
  end

  def handle_call(:start_round, _, state) do
    [current_player | remaining_players] = state.players
    %{state | current_player: current_player, remaining_players: remaining_players}
    state = %{state | round: state.round+1}
    {:reply, :ok, state}
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
    betting_players = Enum.filter(state.players, fn player -> player_state = Cards.Player.get_state(player)
                                            player_state.kamon_bet > 0 end)
    low_card_player = Enum.reduce(betting_players, nil, fn player, acc -> acc = low_card_player(player, acc) end)
    round_winner = round_winner(player_totals(betting_players, low_card_player))
    kamons_won = state.bet_kamons + Enum.at(@kamons_per_round, state.round-1)
    Cards.Player.take_kamons(round_winner, kamons_won)
    {:reply, :ok, state}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:bet_kamon, _, state) do
    {:reply, :ok, %{state | bet_kamons: state.bet_kamons+1}}
  end

  defp player_totals(betting_players, low_card_player) do
    kobayakawa_value = Cards.Card.get_value(Cards.Deck.show_kobayakawa)
    Enum.reduce(betting_players, [], 
      fn player, acc -> player_score = case player do
                          low_card_player -> {player, card_value_of_player(player)+kobayakawa_value}
                           _ -> {player, card_value_of_player(player)}
                        end
                        [player_score | acc]
      end)
  end

  defp round_winner(player_totals) do
    [{first_player, score}|_] = player_totals
    IO.puts "first_player: #{first_player}"
    IO.puts "score: #{score}"
    {round_winner, score} = Enum.reduce(player_totals, nil, fn {player, total}, acc -> 
                                            case acc do
                                              nil -> {player, total}
                                              :true -> if total > elem(acc, 1), do: {player, total}
                                            end
    end)
    round_winner
  end

  defp reward_round_winner(player, kamons_won) do
  end

  defp card_value_of_player(player) do
    [player_card|_] = Cards.Player.show_hand(player)
    Cards.Card.get_value(player_card)
  end
  
  defp low_card_player(player, acc) do
    case acc do
      nil -> player
      :true -> if card_value_of_player(player) > card_value_of_player(acc) do 
                  player
               else
                 acc
               end
    end
  end

end

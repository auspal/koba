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
    IO.puts "     komans bet: #{state.bet_komans}"
    player_state = GenServer.call(state.current_player, :state)
    IO.puts " current player: #{player_state.name}"
  end

  def bet_koman do
    GenServer.call(:round, :bet_koman)
  end

  def next_turn do
    GenServer.call(:round, :next_player)
  end

  # Server callbacks

  def init({deck, players}) do
    {:ok, %{round: 0, bet_komans: 0, deck: deck, players: players, current_player: :player1, remaining_players: players}}
  end

  def handle_call(:start_round, _, state) do
    %{state | remaining_players: state.players}
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

  def handle_call(:bet_koman, _, state) do
    {:reply, :ok, %{state | bet_komans: state.bet_komans+1}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

end

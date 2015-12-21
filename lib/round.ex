defmodule Cards.Round do
  use GenServer

  @number_of_rounds 7
  @kamons_per_round [1,1,1,1,1,1,2]

  def start_link(deck, players) do
    GenServer.start_link(__MODULE__, {deck, players}, name: :round)
  end

  # Client API

  def begin_next_round(server) do
    GenServer.call(server, :start_round)
  end

  def show_state(server) do
    state = GenServer.call(server, :state)
    IO.puts "          round: #{state.round}"
    player_state = GenServer.call(state.current_player, :state)
    IO.puts " current player: #{player_state.name}"
  end

  def next_turn do
    GenServer.call(:round, :next_player)
  end

  # Server callbacks

  def init({deck, players}) do
    {:ok, %{round: 0, deck: deck, players: players, current_player: nil}}
  end

  def handle_call(:start_round, _, state) do
    [first_player | _] = state.players
    state = %{state | round: state.round+1, current_player: first_player}
    {:reply, :ok, state}
  end

  def handle_call(:next_player, _, state) do
    index = Enum.find_index(state.players, fn player -> player == state.current_player end)
    new_player_index = case index do
      3 -> 0
      _ -> index+1
    end
    next_player = Enum.at(state.players, new_player_index)
    {:reply, next_player, %{state | current_player: next_player}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

end

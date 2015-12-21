defmodule Cards.Supervisor do
  use Supervisor

  @deck_name CardsGameSupervisor

  def init(_) do
    IO.puts "****************test1"
    children = [
      supervisor(Cards.Game.Supervior, [])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end

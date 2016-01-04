defmodule Koba do
  use Application

  def start(_type, _args) do
    :random.seed({1450, 803972, 974245}) # for testing purposes
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Koba.Game, [])
    ]

    opts = [strategy: :one_for_one, name: Cards.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

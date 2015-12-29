defmodule Cards.Card do

  def start_link(value) do
    name = String.to_atom("card#{value}")
    Agent.start_link(fn -> value end, [name: name])
    {:ok, name}
  end

  def get_value(agent) do
    Agent.get(agent, fn state -> state end)
  end

end

defmodule Cards.Card do

  def start_link(name) do
    name = String.to_atom(name)
    Agent.start_link(fn -> name end, [name: name])
    {:ok, name}
  end

  def get_value(agent) do
    Agent.get(agent, fn state -> state end)
  end

end

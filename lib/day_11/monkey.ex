defmodule Day11.Monkey do
  use GenServer

  def start_link(name, starting_items, operation, test) do
    IO.inspect("creating monkey")
    {:ok, knot} = GenServer.start_link(__MODULE__, [name, starting_items, operation, test])
    knot
  end

  # Server (callbacks)

  @impl true
  def init([name, starting_items, operation, test]) do
    state = %{
      items: starting_items,
      history: operation,
      tail: test,
      throw_to: %{true => nil, false => nil}
    }

    {:ok, state}
  end
end

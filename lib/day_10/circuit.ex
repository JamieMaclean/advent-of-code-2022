defmodule Day10.Circuit do
  use GenServer

  def start_link([instructions, sample_cycles]) do
    GenServer.start_link(__MODULE__, [instructions, sample_cycles])
  end

  def tic(pid) do
    GenServer.call(pid, :tic)
  end

  def get_samples(pid) do
    GenServer.call(pid, :get_samples)
  end

  # Server (callbacks)

  @impl true
  def init([instructions, sample_cycles]) do
    state = %{
      cycle: 0,
      value: 1,
      blocked: {0, 0},
      samples: [],
      sample_at: sample_cycles,
      instructions: instructions,
      sprites: []
    }

    {:ok, state}
  end

  @impl true
  def handle_call(
        :tic,
        _from,
        %{
          value: value,
          instructions: instructions,
          blocked: {blocked_for, then_add}
        } = state
      ) do
    case {blocked_for, instructions} do
      {1, _} ->
        new_state = %{take_sample(state) | blocked: {0, 0}, value: value + then_add}

        {:reply, :blocked, new_state}

      {0, []} ->
        {:reply, :finished, state}

      {0, _} ->
        new_state =
          take_sample(state)
          |> do_instruction(instructions)

        {:reply, :ok, new_state}

      _ ->
        new_state = %{take_sample(state) | blocked: {blocked_for - 1, then_add}}

        {:reply, :ok, new_state}
    end
  end

  def handle_call(
        :get_samples,
        _from,
        %{samples: samples, sprites: sprites} = state
      ) do
    {:reply, {samples, sprites}, state}
  end

  defp do_instruction(state, [{"noop", _} | rest]) do
    %{state | instructions: rest}
  end

  defp do_instruction(state, [{"addx", number} | rest]) do
    %{state | blocked: {1, number}, instructions: rest}
  end

  defp take_sample(%{sample_at: sample_at, value: value, cycle: cycle, samples: samples} = state) do
    if (cycle + 1) in sample_at do
      %{state | samples: [value * cycle | samples]}
    else
      state
    end
    |> tick()
  end

  defp tick(%{cycle: cycle, value: value, sprites: sprites} = state) do
    %{state | cycle: cycle + 1, sprites: [sprite(value, cycle) | sprites]}
  end

  def sprite(value, cycle) do
    if rem(cycle, 40) in (value - 1)..(value + 1) do
      "#"
    else
      "."
    end
  end
end

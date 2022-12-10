defmodule Day9.Knot do
  use GenServer

  def start_link(tail) do
    {:ok, knot} = GenServer.start_link(__MODULE__, tail)
    knot
  end

  def move(pid, direction) do
    GenServer.cast(pid, {:move, direction})
  end

  def head_moved(pid, head_position) do
    GenServer.cast(pid, {:head_moved, head_position})
  end

  def get_tail_history(pid) do
    GenServer.call(pid, :get_tail_history)
  end

  # Server (callbacks)

  @impl true
  def init(tail) do
    state = %{position: {0, 0}, history: [{0, 0}], tail: tail}
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:move, direciton},
        %{position: {x, y}, history: history, tail: tail}
      ) do
    new_position =
      case direciton do
        "U" -> {x, y + 1}
        "D" -> {x, y - 1}
        "L" -> {x - 1, y}
        "R" -> {x + 1, y}
      end

    if not is_nil(tail) do
      head_moved(tail, new_position)
    end

    {:noreply, %{position: new_position, history: [new_position | history], tail: tail}}
  end

  @impl true
  def handle_cast(
        {:head_moved, head_position},
        %{position: current_position, history: history, tail: tail} = state
      ) do
    new_state =
      if head_within_range?(current_position, head_position) do
        state
      else
        new_position = new_tail_position(current_position, head_position)

        if not is_nil(tail) do
          head_moved(tail, new_position)
        end

        %{state | position: new_position, history: [new_position | history]}
      end

    {:noreply, new_state}
  end

  @impl true
  def handle_call(
        :get_tail_history,
        _from,
        %{history: history, tail: tail} = state
      ) do
    tail_history =
      if is_nil(tail) do
        history
      else
        get_tail_history(tail)
      end

    {:reply, tail_history, state}
  end

  defp new_tail_position({current_x, current_y} = tail, {head_x, head_y}) do
    x_diff = head_x - current_x
    y_diff = head_y - current_y

    {x, y} =
      case distance_to_head(x_diff, y_diff) do
        2.0 -> {current_x + x_diff / 2, current_y + y_diff / 2}
        _ -> move_diagonally(tail, x_diff, y_diff)
      end

    {round(x), round(y)}
  end

  defp move_diagonally({x, y}, x_diff, y_diff) do
    delta_x = x_diff / abs(x_diff)
    delta_y = y_diff / abs(y_diff)

    {x + delta_x, y + delta_y}
  end

  defp distance_to_head(x_diff, y_diff) do
    :math.sqrt(:math.pow(x_diff, 2) + :math.pow(y_diff, 2))
  end

  defp head_within_range?({current_x, current_y}, {head_x, head_y}) do
    (current_x - head_x) in -1..1 && (current_y - head_y) in -1..1
  end
end

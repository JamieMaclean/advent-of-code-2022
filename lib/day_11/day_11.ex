defmodule Day11 do
  def run(file) do
    {monkeys, items, mod} = get_monkeys(file)

    items =
      List.flatten(items)
      |> Enum.map(fn item ->
        complete_rounds(item, monkeys, 10_000, mod)
      end)

    for item <- items, {monkey, _} <- monkeys, reduce: %{} do
      acc ->
        count = Map.get(acc, monkey, 0) + Enum.count(item.history, fn m -> m == monkey end)
        Map.put(acc, monkey, count)
    end
    |> IO.inspect()
  end

  def get_monkeys(filename) do
    instructions =
      File.read!(filename)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    for [
          <<"Monkey ", name::binary-size(1), ":">>,
          <<"  Starting items:", items::binary>>,
          <<"  Operation: new = old ", opr::binary-size(1), 32, opr_subject::binary>>,
          <<"  Test: divisible by ", test_number::binary>>,
          <<"    If true: throw to monkey ", if_true::binary>>,
          <<"    If false: throw to monkey ", if_false::binary>>
        ] <- instructions,
        reduce: {%{}, [], 1} do
      {monkeys, parsed_items, mod} ->
        monkey_name = String.to_integer(name)

        items =
          items
          |> String.replace(" ", "")
          |> String.split(",", trim: true)
          |> Enum.map(fn item ->
            %{
              value: String.to_integer(item),
              history: [monkey_name]
            }
          end)

        monkeys =
          Map.put(monkeys, monkey_name, %{
            opr: create_operation(opr, opr_subject),
            test_opretaion: create_test(test_number),
            throw_to: %{
              true => String.to_integer(if_true),
              false => String.to_integer(if_false)
            }
          })

        {monkeys, [items | parsed_items], mod * String.to_integer(test_number)}
    end
  end

  def complete_rounds(item, monkeys, rounds, mod) do
    for round <- 1..rounds, reduce: item do
      current_item ->
        throw(current_item, monkeys, round == rounds, mod)
    end
  end

  def throw(%{history: [monkey | _rest] = history} = item, monkeys, last_round?, mod) do
    current_monkey = Map.get(monkeys, monkey)
    new_value = rem(current_monkey.opr.(item.value), mod)
    destination = Map.get(current_monkey.throw_to, current_monkey.test_opretaion.(new_value))

    if destination < monkey do
      if last_round? do
        %{
          value: new_value,
          history: history
        }
      else
        %{
          value: new_value,
          history: [destination | history]
        }
      end
    else
      throw(
        %{
          value: new_value,
          history: [destination | history]
        },
        monkeys,
        last_round?,
        mod
      )
    end
  end

  def create_operation("*", "old") do
    fn old -> old * old end
  end

  def create_operation("+", "old") do
    fn old -> old + old end
  end

  def create_operation("*", opr_number) do
    fn old -> old * String.to_integer(opr_number) end
  end

  def create_operation("+", opr_number) do
    fn old -> old + String.to_integer(opr_number) end
  end

  def create_test(number) do
    fn worry_level -> rem(worry_level, String.to_integer(number)) == 0 end
  end
end

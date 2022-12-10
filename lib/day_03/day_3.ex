defmodule Day3 do
  def run(file) do
    part_1 =
      parse_file(file)
      |> prioritize_rucksacks()
      |> IO.inspect(label: "Total Rucksack Priority:")

    part_2 =
      parse_file(file)
      |> prioritize_groups()
      |> IO.inspect(label: "Total Group Priority:")

    {part_1, part_2}
  end

  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
  end

  def prioritize_rucksacks(input) do
    Enum.map(input, fn items ->
      create_rucksack(items)
      |> split_rucksack()
      |> get_duplicated_item()
      |> prioritize_item()
    end)
    |> Enum.sum()
  end

  def prioritize_groups(input) do
    Enum.chunk_every(input, 3)
    |> Enum.map(fn rucksacks ->
      Enum.map(rucksacks, &create_rucksack/1)
      |> get_duplicated_item()
      |> prioritize_item()
    end)
    |> Enum.sum()
  end

  def create_rucksack(string) do
    String.graphemes(string)
  end

  def split_rucksack(items) do
    items_per_compartment = round(length(items) / 2)

    Enum.split(items, items_per_compartment)
    |> Tuple.to_list()
  end

  def get_duplicated_item([item]), do: item

  def get_duplicated_item([compartment_1 | [compartment_2 | rest]]) do
    duplicated_item =
      MapSet.intersection(MapSet.new(compartment_1), MapSet.new(compartment_2))
      |> MapSet.to_list()

    get_duplicated_item([duplicated_item | rest])
  end

  defp prioritize_item([<<letter>>]) when letter in ?a..?z do
    letter - ?a + 1
  end

  defp prioritize_item([<<letter>>]) when letter in ?A..?Z do
    letter - ?A + 27
  end
end

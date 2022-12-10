defmodule Day4 do
  def run(file) do
    pairs =
      get_elf_pairs(file)
      |> get_sections()

    part_1 =
      pairs
      |> get_useless_pairs()
      |> Enum.count()
      |> IO.inspect(label: "Total number of useless pairs:")

    part_2 =
      pairs
      |> get_overlapping_pairs()
      |> Enum.count()
      |> IO.inspect(label: "Total number of overlapping pairs:")

    {part_1, part_2}
  end

  def get_elf_pairs(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
  end

  def get_sections(elf_pairs) do
    Enum.map(elf_pairs, fn pair ->
      String.split(pair, ",")
      |> Enum.map(fn sections ->
        [first, last] =
          String.split(sections, "-", trim: true)
          |> Enum.map(&String.to_integer/1)

        first..last
      end)
    end)
  end

  def get_useless_pairs(elf_pairs) do
    Enum.filter(elf_pairs, &one_range_within_other?/1)
  end

  def get_overlapping_pairs(elf_pairs) do
    Enum.filter(elf_pairs, &overlap?/1)
  end

  def overlap?([min_1..max_1 = range_1, min_2..max_2 = range_2]) do
    cond do
      number_within_range(min_1, range_2) -> true
      number_within_range(max_1, range_2) -> true
      number_within_range(min_2, range_1) -> true
      number_within_range(max_2, range_1) -> true
      true -> false
    end
  end

  def one_range_within_other?([min_1..max_1 = range_1, min_2..max_2 = range_2]) do
    cond do
      number_within_range(min_1, range_2) and number_within_range(max_1, range_2) -> true
      number_within_range(min_2, range_1) and number_within_range(max_2, range_1) -> true
      true -> false
    end
  end

  def number_within_range(number, min..max) do
    number >= min && number <= max
  end
end

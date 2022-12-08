defmodule Day8 do
  defmodule Tree do
    defstruct [:size, visible: false, scenic_score: 1]
  end

  def run(file) do
    forrest =
      get_forrest(file)
      |> survey_forrest()
      |> invert_forrest()
      |> survey_forrest()

    part_1 =
      forrest
      |> count_visible_trees()
      |> IO.inspect(label: "Number of visible trees:")

    part_2 =
      forrest
      |> get_best_tree()
      |> IO.inspect(label: "Tree with most visibility:")

    {part_1, part_2}
  end

  def get_forrest(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      String.graphemes(row)
      |> Enum.map(fn tree_size ->
        %Tree{size: String.to_integer(tree_size)}
      end)
    end)
  end

  def count_visible_trees(forrest) do
    Enum.reduce(forrest, 0, fn row, acc ->
      Enum.reduce(row, acc, fn tree, acc_2 ->
        if tree.visible do
          acc_2 + 1
        else
          acc_2
        end
      end)
    end)
  end

  def get_best_tree(forrest) do
    Enum.reduce(forrest, %Tree{scenic_score: 0}, fn row, acc ->
      Enum.reduce(row, acc, fn tree, acc_2 ->
        if tree.scenic_score > acc_2.scenic_score do
          tree
        else
          acc_2
        end
      end)
    end)
  end

  def invert_forrest(forrest) do
    forrest_height = length(forrest)
    forrest_width = length(Enum.at(forrest, 0))

    for x <- 0..(forrest_height - 1) do
      for y <- 0..(forrest_width - 1) do
        Enum.at(forrest, y)
        |> Enum.at(x)
      end
    end
  end

  def survey_forrest(forrest) do
    Enum.map(forrest, fn [tree | trees_after] ->
      check_row_visability([], tree, trees_after)
      |> check_scenic_score()
    end)
  end

  def check_row_visability([], tree, [next | rest]) do
    tree = struct(tree, visible: true)
    check_row_visability([tree], next, rest)
  end

  def check_row_visability(before, tree, []) do
    tree = struct(tree, visible: true)
    [tree | before]
  end

  def check_row_visability(before, tree, [next | rest] = trees_after) do
    if is_visible?(before, tree, trees_after) do
      tree = struct(tree, visible: true)
      check_row_visability([tree | before], next, rest)
    else
      check_row_visability([tree | before], next, rest)
    end
  end

  def check_scenic_score([first | rest]) do
    check_scenic_score([], first, rest)
  end

  def check_scenic_score([], tree, [next | rest]) do
    tree = struct(tree, scenic_score: 0)
    check_scenic_score([tree], next, rest)
  end

  def check_scenic_score(before, tree, []) do
    tree = struct(tree, scenic_score: 0)
    [tree | before]
  end

  def check_scenic_score(before, tree, [next | rest] = trees_after) do
    scenic_score =
      tree.scenic_score * check_scenic_score(before, tree) *
        check_scenic_score(trees_after, tree)

    tree = struct(tree, scenic_score: scenic_score)
    check_scenic_score([tree | before], next, rest)
  end

  def check_scenic_score(trees, current_tree) do
    Enum.reduce_while(trees, 0, fn tree_before, distance ->
      cond do
        tree_before.size < current_tree.size -> {:cont, distance + 1}
        tree_before.size >= current_tree.size -> {:halt, distance + 1}
      end
    end)
  end

  def is_visible?(trees_before, tree, trees_after) do
    is_visible?(trees_before, tree) || is_visible?(trees_after, tree)
  end

  def is_visible?(outer_trees, tree) do
    Enum.all?(outer_trees, fn outer_tree -> outer_tree.size < tree.size end)
  end
end

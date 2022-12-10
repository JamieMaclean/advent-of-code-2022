defmodule Day8 do
  defmodule Tree do
    defstruct [:size, visible: false, scenic_score: 1]
  end

  def run(file) do
    forrest =
      get_forrest(file)
      |> survey_forrest()
      |> transpose_forrest()
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
    for row <- forrest, tree <- row, tree.visible, reduce: 0 do
      visible_trees -> visible_trees + 1
    end
  end

  def get_best_tree(forrest) do
    for row <- forrest, tree <- row, reduce: %Tree{scenic_score: 0} do
      old_tree ->
        if tree.scenic_score > old_tree.scenic_score do
          tree
        else
          old_tree
        end
    end
  end

  def transpose_forrest(forrest) do
    Enum.zip(forrest)
    |> Enum.map(&Tuple.to_list/1)
  end

  def survey_forrest(forrest) do
    Enum.map(forrest, fn [tree | trees_after] ->
      check_row_visibility([], tree, trees_after)
      |> check_scenic_score()
    end)
  end

  def check_row_visibility([], tree, [next | rest]) do
    tree = struct(tree, visible: true)
    check_row_visibility([tree], next, rest)
  end

  def check_row_visibility(before, tree, []) do
    tree = struct(tree, visible: true)
    [tree | before]
  end

  def check_row_visibility(before, tree, [next | rest] = trees_after) do
    if is_visible?(before, tree, trees_after) do
      tree = struct(tree, visible: true)
      check_row_visibility([tree | before], next, rest)
    else
      check_row_visibility([tree | before], next, rest)
    end
  end

  def is_visible?(trees_before, tree, trees_after) do
    is_visible?(trees_before, tree) || is_visible?(trees_after, tree)
  end

  def is_visible?(outer_trees, tree) do
    Enum.all?(outer_trees, fn outer_tree -> outer_tree.size < tree.size end)
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
end

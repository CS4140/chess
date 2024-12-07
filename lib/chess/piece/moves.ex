# To re-enable all debug messages in this file, run the following command:
# sed 's/#IO/IO/g' -i piece.ex

defmodule Chess.Piece.Moves do
  require Logger

  # Dragon movements (Queen + Knight)
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :dragon, owner: owner},
    [row, col]) do
    Logger.info("Calculating Dragon moves from {#{row}, #{col}}")
    queen_moves = get_queen_moves(cells, [row, col], owner)
    knight_moves = get_knight_moves(cells, [row, col], owner)
    moves = Enum.uniq(queen_moves ++ knight_moves)
    Logger.info("Dragon can move to: #{inspect(moves)}")
    moves
  end

  # Wizard movements (Teleport anywhere empty or capturable)
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :wizard, owner: owner},
    [row, col]) do
    Logger.info("Calculating Wizard moves from {#{row}, #{col}}")
    moves = for r <- 0..7,
      c <- 0..7,
    [r, c] != [row, col],
      cells[[r, c]] == nil || cells[[r, c]].owner != owner,
      do: [r, c]
    Logger.info("Wizard can move to: #{inspect(moves)}")
    moves
  end

  # Ninja movements (Knight + Adjacent)
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :ninja, owner: owner},
    [row, col]) do
    Logger.info("Calculating Ninja moves from {#{row}, #{col}}")
    knight_moves = get_knight_moves(cells, [row, col], owner)
    adjacent_moves = get_adjacent_moves(cells, [row, col], owner)
    moves = Enum.uniq(knight_moves ++ adjacent_moves)
    Logger.info("Ninja can move to: #{inspect(moves)}")
    moves
  end

  # Phoenix movements (Jumping diagonals)
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :phoenix, owner: owner},
    [row, col]) do
    Logger.info("Calculating Phoenix moves from {#{row}, #{col}}")
    moves = get_diagonal_jumping_moves(cells, [row, col], owner)
    Logger.info("Phoenix can move to: #{inspect(moves)}")
    moves
  end

  # King movements (One square in any direction)
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :king, owner: owner},
    [row, col]) do
    Logger.info("Calculating King moves from {#{row}, #{col}}")
    moves = get_adjacent_moves(cells, [row, col], owner)
    Logger.info("King can move to: #{inspect(moves)}")
    moves
  end

  # Pawn movements
  def get(%Chess.Board{cells: cells},
    %Chess.Piece{type: :pawn, owner: owner},
    [row, col]) do
    Logger.info("Calculating Pawn moves from {#{row}, #{col}}")
    direction = if owner == :white, do: -1, else: 1
    start_col = if owner == :white, do: 6, else: 1

    # Forward moves
    forward_moves = 
    if valid_position?([row, col + direction]) && cells[[row, col + direction]] == nil do
      moves = [[row, col + direction]]
      if col == start_col && 
        valid_position?([row, col + (direction * 2)]) && 
        cells[[row, col + (direction * 2)]] == nil do
        [[row, col + (direction * 2)] | moves]
      else
        moves
      end
    else
      []
    end

    # Capture moves
    capture_moves =
      [[row - 1, col + direction], [row + 1, col + direction]]
      |> Enum.filter(fn pos ->
      valid_position?(pos) &&
        cells[pos] != nil &&
        cells[pos].owner != owner
    end)

      moves = forward_moves ++ capture_moves
      Logger.info("Pawn can move to: #{inspect(moves)}")
      moves
  end

  def get(%Chess.Board{cells: cells},
    %Chess.Piece{owner: owner, type: :rook},
    [row, col]) do
    IO.puts("\n=== Rook Move Calculation ===")
    IO.inspect([row, col, owner], label: "Calculating moves for rook")

    # Calculate moves in each direction
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]  # Up, Down, Right, Left
    
    moves = Enum.flat_map(directions, fn [row_dir, col_dir] ->
      find_moves_in_direction(cells, [row, col], [row_dir, col_dir], owner)
    end)

    IO.inspect(moves, label: "Valid rook moves")
    moves
  end

  def get(%Chess.Board{cells: cells},
    %Chess.Piece{owner: owner, type: :bishop},
    [row, col]) do
    IO.puts("\n=== Bishop Move Calculation ===")
    IO.inspect({row, col, owner}, label: "Calculating moves for bishop")

    # Calculate moves in diagonal directions
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    
    moves = Enum.flat_map(directions, fn [row_dir, col_dir] ->
      find_moves_in_direction(cells, [row, col], [row_dir, col_dir], owner)
    end)

    IO.inspect(moves, label: "Valid bishop moves")
    moves
  end

  def get(%Chess.Board{cells: cells},
    %Chess.Piece{owner: owner, type: :queen},
    [row, col]) do
    IO.puts("\n=== Queen Move Calculation ===")
    IO.inspect({row, col, owner}, label: "Calculating moves for queen")

    # Combine rook and bishop moves
    directions = [
      [0, 1], [0, -1], [1, 0], [-1, 0],  # Rook moves
      [1, 1], [1, -1], [-1, 1], [-1, -1]  # Bishop moves
    ]
    
    moves = Enum.flat_map(directions, fn [row_dir, col_dir] ->
      find_moves_in_direction(cells, [row, col], [row_dir, col_dir], owner)
    end)

    IO.inspect(moves, label: "Valid queen moves")
    moves
  end

  def get(%Chess.Board{cells: cells},
    %Chess.Piece{owner: owner, type: :knight},
    [row, col]) do
    IO.puts("\n=== Knight Move Calculation ===")
    IO.inspect({row, col, owner}, label: "Calculating moves for knight")

    moves = [
      [row + 2, col + 1], [row + 2, col - 1],
      [row - 2, col + 1], [row - 2, col - 1],
      [row + 1, col + 2], [row + 1, col - 2],
      [row - 1, col + 2], [row - 1, col - 2]
    ]

    valid_moves = Enum.filter(moves, fn pos ->
      Map.has_key?(cells, pos) and
      (cells[pos] == nil or cells[pos].owner != owner)
    end)

    IO.inspect(valid_moves, label: "Valid knight moves")
    valid_moves
  end

  # Helper functions
  defp get_queen_moves(cells, [row, col], owner) do
    directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ]
    
    Enum.flat_map(directions, fn {dr, dc} ->
      get_line_moves(cells, [row, col], {dr, dc}, owner)
    end)
  end

  defp get_knight_moves(cells, [row, col], owner) do
    [
      [row + 2, col + 1], [row + 2, col - 1],
      [row - 2, col + 1], [row - 2, col - 1],
      [row + 1, col + 2], [row + 1, col - 2],
      [row - 1, col + 2], [row - 1, col - 2]
    ]
    |> Enum.filter(fn pos ->
      valid_position?(pos) && (cells[pos] == nil || cells[pos].owner != owner)
    end)
  end

  defp get_adjacent_moves(cells, [row, col], owner) do
    [
      [row - 1, col - 1], [row - 1, col], [row - 1, col + 1],
      [row, col - 1],                     [row, col + 1],
      [row + 1, col - 1], [row + 1, col], [row + 1, col + 1]
    ]
    |> Enum.filter(fn pos ->
      valid_position?(pos) && (cells[pos] == nil || cells[pos].owner != owner)
    end)
  end

  defp get_diagonal_jumping_moves(cells, [row, col], owner) do
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    
    Enum.flat_map(directions, fn {dr, dc} = dir ->
      Logger.info("Phoenix checking direction #{inspect(dir)}")
      moves = get_phoenix_line(cells, [row, col], [dr, dc], owner)
      Logger.info("Phoenix moves in direction #{inspect(dir)}: #{inspect(moves)}")
      moves
    end)
  end

  defp get_line_moves(cells, [row, col], [dr, dc], owner, acc \\ []) do
    new_pos = [row + dr, col + dc]
    
    cond do
      !valid_position?(new_pos) -> 
        acc
      cells[new_pos] == nil ->
        get_line_moves(cells, new_pos, [dr, dc], owner, [new_pos | acc])
      cells[new_pos].owner != owner -> 
        [new_pos | acc]
      true -> 
        acc
    end
  end

  defp get_phoenix_line(cells, [row, col], [dr, dc], owner, acc \\ []) do
    new_pos = [row + dr, col + dc]
    
    cond do
      !valid_position?(new_pos) ->
        Enum.reverse(acc)
      true ->
        case cells[new_pos] do
          nil ->
            get_phoenix_line(cells, new_pos, [dr, dc], owner, [new_pos | acc])
          piece when piece.owner != owner ->
            get_phoenix_line(cells, new_pos, [dr, dc], owner, [new_pos | acc])
          _piece ->
            get_phoenix_line(cells, new_pos, [dr, dc], owner, acc)
        end
    end
  end

  defp valid_position?([row, col]) do
    row >= 0 && row < 8 && col >= 0 && col < 8
  end

  # Helper function to find moves in a specific direction until blocked
  defp find_moves_in_direction(cells, [row, col], [row_dir, col_dir], owner) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while([], fn i, acc ->
      new_pos = [row + (i * row_dir), col + (i * col_dir)]
      
      cond do
        !Map.has_key?(cells, new_pos) ->
          {:halt, acc}
        cells[new_pos] == nil ->
          {:cont, [new_pos | acc]}
        cells[new_pos].owner != owner ->
          {:halt, [new_pos | acc]}
        true ->
          {:halt, acc}
      end
    end)
  end
end

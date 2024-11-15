defmodule Chess.Piece do
  defstruct color: nil,
            type: nil

  def glyphs() do
    %{:white =>
        %{:rook => "♖", :knight => "♘", :bishop => "♗", :queen => "♕", :king => "♔", :pawn => "♙"},
      :black =>
        %{:rook => "♜", :knight => "♞", :bishop => "♝", :queen => "♛", :king => "♚", :pawn => "♟"},
    }
  end

  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :king},
                     {row, col}) do
    IO.puts("\n=== King Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for king")

    # king can move to any one (1) adjacent space
    moves = [
      {row + 0, col + 1},  # Forward
      {row + 1, col + 1},  # Forward-right
      {row + 1, col + 0},  # Right
      {row + 1, col - 1},  # Back-right
      {row + 0, col - 1},  # Back
      {row - 1, col - 1},  # Back-left
      {row - 1, col + 0},  # Left
      {row - 1, col + 1},  # Forward-left
    ]

    valid_moves = Enum.filter(moves, fn pos ->
      Map.has_key?(cells, pos) and
        (cells[pos] == nil or cells[pos].color != color)
    end)

    IO.inspect(valid_moves, label: "Valid king moves")
    valid_moves
  end

  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :rook},
                     {row, col}) do
    IO.puts("\n=== Rook Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for rook")

    # Calculate moves in each direction
    directions = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]  # Up, Down, Right, Left
    
    moves = Enum.flat_map(directions, fn {row_dir, col_dir} ->
      find_moves_in_direction(cells, {row, col}, {row_dir, col_dir}, color)
    end)

    IO.inspect(moves, label: "Valid rook moves")
    moves
  end

  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :bishop},
                     {row, col}) do
    IO.puts("\n=== Bishop Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for bishop")

    # Calculate moves in diagonal directions
    directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    
    moves = Enum.flat_map(directions, fn {row_dir, col_dir} ->
      find_moves_in_direction(cells, {row, col}, {row_dir, col_dir}, color)
    end)

    IO.inspect(moves, label: "Valid bishop moves")
    moves
  end

  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :queen},
                     {row, col}) do
    IO.puts("\n=== Queen Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for queen")

    # Combine rook and bishop moves
    directions = [
      {0, 1}, {0, -1}, {1, 0}, {-1, 0},  # Rook moves
      {1, 1}, {1, -1}, {-1, 1}, {-1, -1}  # Bishop moves
    ]
    
    moves = Enum.flat_map(directions, fn {row_dir, col_dir} ->
      find_moves_in_direction(cells, {row, col}, {row_dir, col_dir}, color)
    end)

    IO.inspect(moves, label: "Valid queen moves")
    moves
  end

  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :knight},
                     {row, col}) do
    IO.puts("\n=== Knight Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for knight")

    moves = [
      {row + 2, col + 1}, {row + 2, col - 1},
      {row - 2, col + 1}, {row - 2, col - 1},
      {row + 1, col + 2}, {row + 1, col - 2},
      {row - 1, col + 2}, {row - 1, col - 2}
    ]

    valid_moves = Enum.filter(moves, fn pos ->
      Map.has_key?(cells, pos) and
        (cells[pos] == nil or cells[pos].color != color)
    end)

    IO.inspect(valid_moves, label: "Valid knight moves")
    valid_moves
  end

  # Pawn moves - keeping your existing implementation as it works correctly
  def possible_moves(%Chess.Board{cells: cells, capture_piles: capture_piles},
                     %Chess.Piece{color: color, type: :pawn},
                     {row, col}) do
    direction = if color == :white, do: -1, else: 1
    start_col = if color == :white, do: 6, else: 1

    IO.puts("\n=== Pawn Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating moves for pawn")
    IO.inspect(direction, label: "Movement direction")
    IO.inspect(start_col, label: "Starting column")

    # Forward moves
    forward_moves = 
      if Map.has_key?(cells, {row, col + direction}) do
        IO.puts("Checking forward to {#{row}, #{col + direction}}")
        if cells[{row, col + direction}] == nil do
          one_forward = {row, col + direction}
          moves = [one_forward]
          IO.puts("One move forward available: #{inspect(one_forward)}")

          if col == start_col do
            two_forward = {row, col + (direction * 2)}
            IO.puts("Checking two forward to #{inspect(two_forward)}")
            if Map.has_key?(cells, two_forward) && cells[two_forward] == nil do
              IO.puts("Two moves forward available")
              [two_forward | moves]
            else
              moves
            end
          else
            moves
          end
        else
          IO.puts("Forward square is blocked")
          []
        end
      else
        IO.puts("Forward square is off board")
        []
      end

    capture_positions = [
      {row - 1, col + direction},  # Capture left diagonal
      {row + 1, col + direction}   # Capture right diagonal
    ]

    IO.inspect(capture_positions, label: "Checking capture positions")

    capture_moves = 
      capture_positions
      |> Enum.filter(fn pos ->
        IO.inspect(pos, label: "Checking position")
        if Map.has_key?(cells, pos) && cells[pos] != nil do
          enemy = cells[pos].color != color
          IO.puts("Found #{cells[pos].color} piece, can capture: #{enemy}")
          enemy
        else
          IO.puts("No capturable piece")
          false
        end
      end)

    IO.inspect(forward_moves, label: "Forward moves")
    IO.inspect(capture_moves, label: "Capture moves")

    all_moves = forward_moves ++ capture_moves
    IO.inspect(all_moves, label: "All valid moves")
    all_moves
  end

  # Helper function to find moves in a specific direction until blocked
  defp find_moves_in_direction(cells, {row, col}, {row_dir, col_dir}, color) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while([], fn i, acc ->
      new_pos = {row + (i * row_dir), col + (i * col_dir)}
      
      cond do
        !Map.has_key?(cells, new_pos) ->
          {:halt, acc}
        cells[new_pos] == nil ->
          {:cont, [new_pos | acc]}
        cells[new_pos].color != color ->
          {:halt, [new_pos | acc]}
        true ->
          {:halt, acc}
      end
    end)
  end
end

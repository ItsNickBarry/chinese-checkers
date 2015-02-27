require 'byebug'
class Board
  attr_accessor :grid

  COLORS = { one: :red, two: :yellow, three: :green, four: :cyan, five: :blue, six: :magenta, nil => :white }
  DIRECTIONS = { right: :left, left: :right, upright: :downleft, upleft: :downright, downright: :upleft, downleft: :upright }
  ROW_SIZES = [1, 2, 3, 4, 13, 12, 11, 10, 9, 10, 11, 12, 13, 4, 3, 2, 1]
  ROW_OFFSETS = { left: 0, right: 0, upleft: -1, upright: -1, downleft: 1, downright: 1 }

  def initialize(fill = true)
    @grid = Array.new(17) { |i| Array.new(ROW_SIZES[i]) }
    populate_board if fill
  end

  def [](position)
    @grid[position[0]][position[1]]
  end

  def []=(position, value)
    @grid[position[0]][position[1]] = value
  end

  def execute_move(from, to, player)
    raise OutOfBoundsError.new unless in_bounds?(from) && in_bounds?(to)
    raise PieceNotOwnedError.new unless self[from] == player
    raise IllegalMoveError.new unless moves(from).include?(to) || jump_chains(from).include?(to)

    self[from] = nil
    self[to] = player
  end

  def moves(position)
    legal_moves = []
    DIRECTIONS.keys.each do |direction|
      step_move = step(position, direction)
      next unless in_bounds?(step_move)
      if self[step_move].nil?
        legal_moves << step_move
      else
        jump_move = jump(position, direction)
        if in_bounds?(jump_move) && self[jump_move].nil?
          legal_moves << jump_move
          legal_moves += jump_chains(position)
        end
      end
    end
    legal_moves -= [position]
    legal_moves.uniq
  end

  def jump_chains(position)
    legal_moves = []
    DIRECTIONS.keys.each do |direction|
      jump_move = jump(position, direction)
      step_move = step(position, direction)
      next unless in_bounds?(jump_move) && self[jump_move].nil? && !self[step_move].nil?

      duplicate_board = self.dup
      duplicate_board[position] = :seven
      legal_moves << jump_move
      legal_moves += duplicate_board.jump_chains(jump_move)
    end
    legal_moves
  end


  def in_bounds?(position)
    row_size = ROW_SIZES[position[0]]
    row_size && position[1].between?(0, row_size - 1)
  end

  def step(from, direction)
    return [from[0], from[1] + 1] if direction == :right
    return [from[0], from[1] - 1] if direction == :left

    from_row = from[0]
    to_row = from_row + ROW_OFFSETS[direction]

    from_row_size = ROW_SIZES[from_row]
    to_row_size = ROW_SIZES[to_row]

    row_size_difference = to_row_size - from_row_size

    if direction == :downleft || direction == :upleft
      return [to_row, from[1] + row_size_difference / 2]
    end
    if direction == :downright || direction == :upright
      return [to_row, from[1] + 1 + row_size_difference / 2]
    end

    raise "Invalid direction"
  end

  def jump(from, direction)
    step(step(from, direction), direction)
  end

  def graph
    letters = " " + "            " + "a b c d e f g h i j k l m n o p q r s t "
    @grid.each_with_index do |row, index|
      row_str = "#{index.to_s.rjust(2)} : #{row.length.to_s.rjust(2)} " + (" ") * (13 - row.length)
      row.each do |col|
        row_str += "#{icon(col)} "
      end
      puts row_str
    end
    puts letters
  end

  def dup
    duplicate = Board.new(false)
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        duplicate[[row_index, col_index]] = col
      end
    end
    duplicate
  end

  private

    def icon(holder)
      '●'.colorize(COLORS[holder])
    end

    def populate_board
      # top
      @grid[0..3].each do |row|
        row.map! { :one }
      end
      # bottom
      @grid[-4..-1].each do |row|
        row.map! { :four }
      end
      # upper middle
      @grid[4..7].each_with_index do |row, index|
        count = (index - 3).abs
        (0..count).each do |col|
          row[col] = :six
          row[-1 - col] = :two
        end
      end
      # lower middle
      @grid[9..12].each_with_index do |row, index|
        count = index
        (0..count).each do |col|
          row[col] = :five
          row[-1 - col] = :three
        end
      end
    end
end

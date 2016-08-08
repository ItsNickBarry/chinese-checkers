class Board
  attr_accessor :grid, :player_colors

  PLAYERS = [:one, :two, :three, :four, :five, :six]
  COLORS = [:red, :green, :blue, :cyan, :magenta, :yellow]
  DIRECTIONS = { right: :left, left: :right, upright: :downleft, upleft: :downright, downright: :upleft, downleft: :upright }
  ROW_SIZES = [1, 2, 3, 4, 13, 12, 11, 10, 9, 10, 11, 12, 13, 4, 3, 2, 1, 0]
  ROW_OFFSETS = { left: 0, right: 0, upleft: -1, upright: -1, downleft: 1, downright: 1 }

  FOUR_POSITIONS = [[0,0], [1,0], [1,1], [2,0], [2,1], [2,2], [3,0], [3,1], [3,2], [3,3]]
  FIVE_POSITIONS = [[4,9], [4,10], [4,11], [4,12]]

  def initialize(options = {})
    @player_colors = Hash[PLAYERS.zip(COLORS.shuffle)]
    @grid = Array.new(17) { |i| Array.new(ROW_SIZES[i]) }
    @players = options[:players] || []
    populate_board
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
    to_row_size = ROW_SIZES[to_row] || -1000

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

  def render(options = {})
    puts graph(options)
  end

  def winner
    # TODO make these into constants, or add parameter to check only current player
    return :four if @grid[0..3].flatten.all? { |position| position == :four }
    return :one if @grid[-4..-1].flatten.all? { |position| position == :one }

    three_positions = []
    five_positions = []

    @grid[4..7].each_with_index do |row, index|
      count = (index - 3).abs
      (0..count).each do |col|
        three_positions << row[col]
        five_positions << row[-1 - col]
      end
    end

    return :three if three_positions.all? { |position| position == :three }
    return :five if five_positions.all? { |position| position == :five }

    two_positions = []
    six_positions = []

    @grid[9..12].each_with_index do |row, index|
      count = index
      (0..count).each do |col|
        two_positions << row[col]
        six_positions << row[-1 - col]
      end
    end

    return :two if two_positions.all? { |position| position == :two }
    return :six if six_positions.all? { |position| position == :six }

    nil
  end

  def pieces_of(number)
    pieces = []
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        pieces << [row_index, col_index] if piece == number
      end
    end
    pieces
  end

  def movable_pieces_of(number)
    pieces_of(number).select { |position| moves(position) != [] }
  end

  def dup
    duplicate = Board.new()
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        duplicate[[row_index, col_index]] = col
      end
    end
    duplicate
  end

  private

    def icon(holder, selected = false, targeted = false)
      (targeted ? '◎' : selected ? '◉' : '●').colorize(@player_colors[holder])
    end

    def graph(options = {})
      graph = ""
      @grid.each_with_index do |row, row_index|
        row_str = (" ") * (13 - row.length)
        row.each_with_index do |col, col_index|
          here = [row_index, col_index]
          row_str += "#{icon(col, options[:selected] == [row_index, col_index], options[:targeted] == [row_index, col_index])} "
        end
        graph << row_str << "\n"
      end
      graph
    end

    def populate_board
      # top
      if @players.include?(:one)
        @grid[0..3].each do |row|
          row.map! { :one }
        end
      end
      # bottom
      if@players.include?(:four)
        @grid[-4..-1].each do |row|
          row.map! { :four }
        end
      end
      # upper middle
      @grid[4..7].each_with_index do |row, index|
        count = (index - 3).abs
        (0..count).each do |col|
          row[col] = :six if @players.include?(:six)
          row[-1 - col] = :two if @players.include?(:two)
        end
      end
      # lower middle
      @grid[9..12].each_with_index do |row, index|
        count = index
        (0..count).each do |col|
          row[col] = :five if @players.include?(:five)
          row[-1 - col] = :three if @players.include?(:three)
        end
      end
    end
end

class HumanPlayer
  attr_reader :name
  attr_accessor :number

  def initialize(name, number = nil)
    @name = name
    @number = number
  end

  def input_move(board)
    begin
      moves = []
      tab_moves = board.movable_pieces_of(@number)
      current_position = tab_moves.first
      system "clear"

      until moves.length == 2
        board.render({ selected: moves[0], targeted: current_position })
        puts "\n#{@name}, it is your turn."
        puts "\nPress tab to cycle through positions, and enter to select position."
        puts "Press backspace to deselect a piece."

        keypress = read_keypress

        case keypress
        when "\t"
          tab_moves << tab_moves.shift
          step = tab_moves.first
        when "\r"
          # TODO only allow selecting of movable pieces / valid target positions
          moves << current_position
          tab_moves = board.moves(current_position)
        when "o"
          step = board.step(current_position, :upright)
        when "m"
          step = board.step(current_position, :downleft)
        when "l"
          step = board.step(current_position, :right)
        when "j"
          step = board.step(current_position, :left)
        when "i"
          step = board.step(current_position, :upleft)
        when ","
          step = board.step(current_position, :downright)
        when "\177"
          moves.pop
          tab_moves = board.movable_pieces_of(@number)
        when "\u0003"
          exit 0
        end
        current_position = step if board.in_bounds?(step) if step
          system "clear"
      end
    rescue => e
      puts e.message
      retry
    end
    moves
  end

  def read_keypress
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end
end

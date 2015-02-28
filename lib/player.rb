class HumanPlayer
  attr_reader :name
  attr_accessor :number

  def initialize(name, number = nil)
    @name = name
    @number = number
  end

  def send_message(message)
    puts message
  end

  def input_move(board)
    puts "#{@name}, please select a sequence of tiles to move your piece. (jiol,m to move, enter to select, ctrl + enter to submit)"
    begin
      current_position = [8, 4]
      moves = []
      until moves.length == 2
        board.render(current_position)
        puts "Selected piece: #{moves[0]}" if moves.length == 1
        keypress = read_keypress

        case keypress
        when "\r"
          moves << current_position
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
        when "\u0003"
          exit 0
        end
        current_position = step if board.in_bounds?(step) if step
      end
    rescue => e
      send_message(e.message)
      send_message(e.backtrace)
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

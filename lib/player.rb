class HumanPlayer
  def initialize(name)
    @name = name
  end

  def send_message(message)
    puts message
  end

  def input_move
    puts "#{@name}, please enter a sequence of tiles to move your piece."
    begin
      move = gets.chomp.downcase
      raise InputError.new unless move.match(/\A([a-h][1-8][, ]+)+[a-h][1-8]\Z/)
    rescue => e
      send_message(e. message)
      retry
    end

    move.split(/[, ]+/)
  end
end

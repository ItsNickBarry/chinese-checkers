require_relative 'board'
require_relative 'errors'
require_relative 'player'
require 'colorize'
require 'io/console'

class ChineseCheckers
  def initialize(options = {})
    @turn_count = 0
    @players = options[:players]
    board_players = case @players.length
    when 2
      [:one, :four]
    when 3
      [:one, :three, :five]
    when 4
      [:two, :three, :five, :six]
    when 6
      [:one, :two, :three, :four, :five, :six]
    else
      raise PlayerCountError.new
    end

    @players.each_with_index do |player, index|
      player.number = board_players[index]
    end

    @board = Board.new({ players: board_players })
  end

  def play
    until @board.winner
      begin
        move = current_player.input_move(@board)
        @board.execute_move(move.first, move.last, current_player.number)
      rescue => e
        puts e.message
        puts e.backtrace
        retry
      end

      @turn_count += 1
    end
    @board.render
    puts "#{current_player.name} of the #{@board.player_colors[current_player.number]}s wins."
  end

  def current_player
    @players[@turn_count % @players.length]
  end
end


if __FILE__ == $0
  puts "Welcome to Chinese Checkers.  Who will play this round? (enter 2, 3, 4, or 6 names, separated by commas)"
  begin
    players = gets.chomp.split(",").map(&:strip).map { |name| HumanPlayer.new(name) }
    raise PlayerCountError.new unless [2,3,4,6].include?(players.length)
  rescue => e
    puts e.message
  end
  game = ChineseCheckers.new({ players: players })
  game.play
end

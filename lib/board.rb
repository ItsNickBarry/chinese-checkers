require 'colorize'

class Board
  attr_accessor :grid

  ROW_SIZES = [1, 2, 3, 4, 13, 12, 11, 10, 9, 10, 11, 12, 13, 4, 3, 2, 1]

  def initialize
    @grid = Array.new(17) { |i| Array.new(ROW_SIZES[i]) }
  end

  def step(from, direction)

    [[0, 1], [0, -1]] #right, left
    # upleft up left right down downright
    #[[-1, -1], [-1, 0], [0, -1], [0, 1], [1, 0], [1, 1]]


  end

  def jump(from, direction)
    # 2 steps
  end

  def graph
    @grid.each_with_index do |row, index|
      row_str = "#{index.to_s.rjust(2)} : #{row.length.to_s.rjust(2)} " + " " * (13 - row.length)
      row.each do |col|
        row_str += icon(col) + " "
      end
      puts row_str
    end
    nil
  end

  private

    def icon(holder)
      '●'.colorize({ one: :red, two: :cyan, three: :green, four: :yellow, five: :blue, six: :magenta, nil => :white }[holder])
    end
end

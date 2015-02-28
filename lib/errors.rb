class InputError < ArgumentError
  def message
    "Invalid input format."
  end
end

class OutOfBoundsError < ArgumentError
  def message
    "You have specified a position which is out of the bounds of the board."
  end
end

class PieceNotOwnedError < ArgumentError
  def message
    "You do not own that piece."
  end
end

class IllegalMoveError < ArgumentError
  def message
    "That move is not legal."
  end
end

class PlayerCountError < StandardError
  def message
    "Game must be played with 2, 3, 4, or 6 players."
  end
end

class Board
  attr_accessor :hidden_board, :board

  def initialize
    @board = Array.new(9) {"*" * 9}
    @hidden_board = Array.new(9) {"*" * 9}
    place_bombs
  end

  def place_bombs
    10.times do |i|
      x, y = rand(9), rand(9)
      until @hidden_board[x][y] == "*"
        x, y = rand(9), rand(9)
      end

      @hidden_board[x][y] = "B"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  b = Board.new
  b.place_bombs
  puts b.hidden_board
end
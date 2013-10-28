class Board
  attr_accessor :hidden_board, :board

  MOVES = [
    [-1,1],
    [-1,0],
    [-1,1],
    [0,-1],
    [0,1],
    [1,-1],
    [1,0],
    [1,1]
  ]

  def initialize
    @board = Array.new(9) {"*" * 9}
    @hidden_board = Array.new(9) {"*" * 9}
    place_bombs
    # place_numbers
  end

  # private

  def place_bombs
    10.times do |i|
      x, y = rand(9), rand(9)
      until @hidden_board[x][y] == "*"
        x, y = rand(9), rand(9)
      end

      @hidden_board[x][y] = "B"
    end
  end

  # def place_numbers
#     hidden_board.dup.each_with_index do |row, row_index|
#       row.each_with_index do |entry, col_index|
#         bombs_near = 0
#
#       end
#     end
#   end

  def valid_moves(x,y) # returns an array of legal squares
    valid_moves = []
    MOVES.each do |x_inc,y_inc|
      new_x = x + x_inc
      new_y = y + y_inc
      if new_x.between?(0,9) && new_y.between?(0, 9)
        valid_moves << [new_x, new_y]
      end
    end

    valid_moves
  end

#   def count_bombs(x,y) # takes the results of valid_moves and counts the bombs
#
#   end
end

if $PROGRAM_NAME == __FILE__
  b = Board.new
  b.place_bombs
  p b.valid_moves(0,0)
  p b.valid_moves(3,3)
  p b.valid_moves(0,3)
end
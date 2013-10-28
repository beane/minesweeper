require 'debugger'
class Board
  attr_accessor :hidden_board, :board

  MOVES = [
    [-1,-1],
    [-1,0],
    [-1,1],
    [0,-1],
    [0,1],
    [1,-1],
    [1,0],
    [1,1]
  ]

  BOMB = "B"
  EMPTY = "*"

  def initialize
    @board = Array.new(9) {EMPTY * 9}
    @hidden_board = Array.new(9) {EMPTY * 9}
    place_bombs
    place_numbers
  end

  private

  def place_bombs
    10.times do |i|
      x, y = rand(9), rand(9)
      until hidden_board[x][y] == EMPTY
        x, y = rand(9), rand(9)
      end

      hidden_board[x][y] = BOMB
    end
  end

  def place_numbers
    hidden_board.dup.each_with_index do |row, x|
      row.split('').each_with_index do |entry, y|
        hidden_board[x][y] = count_bombs(x,y).to_s unless entry == BOMB
      end
    end
  end

  def valid_moves(x,y) # returns an array of legal squares
    valid_moves = []
    MOVES.each do |x_inc,y_inc|
      new_x = x + x_inc
      new_y = y + y_inc
      if new_x.between?(0,8) && new_y.between?(0, 8)
        valid_moves << [new_x, new_y]
      end
    end

    valid_moves
  end

  def count_bombs(x,y) # takes the results of valid_moves and counts the bombs
    bombs = 0

    valid_moves(x,y).each do |coord_pair|
      test_x, test_y = coord_pair
      bombs += 1 if hidden_board[test_x][test_y] == BOMB
    end

    bombs
  end
end

if $PROGRAM_NAME == __FILE__
  b = Board.new
  puts b.hidden_board
end
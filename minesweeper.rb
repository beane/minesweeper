require 'debugger'

class Minesweeper
  attr_reader :board, :still_alive

  def initialize
    @board = Board.new
    @still_alive = true
  end

  def play_move
    puts "Pick a square (x,y): "
    x, y = gets.strip.split(',').map(&:to_i)

    still_alive = board.reveal(x,y)
    puts "BOMB! You lose." unless still_alive
  end

  def play_flag
    puts "Pick a square (x,y): "
    x, y = gets.strip.split(',').map(&:to_i)

    board.toggle_flag(x,y)
  end

  def run
    puts "Welcome to Minesweeper"

    while still_alive
      puts board.to_s
      puts "Flag a square (0) or move (1): "
      selection = gets.to_i

      if selection == 0
        play_flag
      else
        play_move
      end

      if board.won?
        puts "Congratulations!!!111!!!ROFLCOPTERAIRFORCE"
        return
      end
    end
  end

  def to_s
    board.to_s
  end
end

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
  UNEXPLORED = "*"
  NO_BOMBS = '_'
  FLAG = "F"

  def initialize
    @board = Array.new(9) {UNEXPLORED * 9}
    @hidden_board = Array.new(9) {UNEXPLORED * 9}
    place_bombs
    place_numbers
  end

  def reveal(x, y) # REFACTOR OR DIE!!!
    ints = ('1'..'8').to_a
    hidden_square = hidden_board[x][y]
    return false if hidden_square == BOMB

    if ints.include?(hidden_square)
      board[x][y] = hidden_square
      return true
    end

    squares_to_reveal = [[x,y]]

    until squares_to_reveal.empty?
      x1, y1 = squares_to_reveal.shift
      hidden_square = hidden_board[x1][y1]

      board[x1][y1] = hidden_square

      valid_moves(x1,y1).each do |square|
        x2, y2 = square
        board_square = board[x2][y2]
        hidden_square = hidden_board[x2][y2]

        next if hidden_square == BOMB
        next unless board_square == UNEXPLORED

        squares_to_reveal << [x2,y2] if hidden_square == '_'
        board[x2][y2] = hidden_square if ints.include?(hidden_square)
      end
    end

      # if you try to reveal a square with a number in it,
      # you will just change the board at those coordinates to
      # show the number

    true
  end

  def toggle_flag(x, y)
    if board[x][y] == FLAG
      board[x][y] = UNEXPLORED
    elsif board[x][y] == UNEXPLORED
      board[x][y] = FLAG
    end
  end

  def won?
    b = []
    board.each_with_index do |row, x|
      new_row = []

      row.split("").each_with_index do |square, y|
        if square == FLAG or square == UNEXPLORED
          new_row << BOMB
        else
          new_row << square
        end
      end

      b << new_row.join('')
    end

    b == hidden_board
  end

  def to_s
    board
  end

  private

  def place_bombs
    10.times do |i|
      x, y = rand(9), rand(9)
      until hidden_board[x][y] == UNEXPLORED
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

    return NO_BOMBS if bombs == 0
    bombs
  end
end

class Array
  def clone
    map { |el| el.is_a?(Array) ? el.dup : el }
  end
end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  g.run
end
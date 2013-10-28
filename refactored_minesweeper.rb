require 'debugger'
class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

end

class Board
  attr_accessor :tiles

  MOVES = [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0],[1,1]]

  def initialize
    @tiles = Array.new(9) {Array.new * 9}
    @tiles.each do |row|
      9.times { row << Tile.new }
    end

    place_bombs

    (0..8).each do |x|
      (0..8).each do |y|
        calculate_adjacencies(x,y)
      end
    end
  end

  def place_bombs
    10.times do
      x, y = rand(9), rand(9)
      until tiles[x][y].bomb == false
        x, y = rand(9), rand(9)
      end

      tiles[x][y].bomb = true
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

  def calculate_adjacencies(x,y)
    # debugger
    tile = tiles[x][y]
    valid_moves(x,y).each do |pos|
      tile.adjacent_tiles << tiles[pos[0]][pos[1]]
    end
  end

end

class Tile
  attr_accessor :bomb, :state, :adjacent_tiles, :adjacent_bombs

  def initialize
    @state = :hidden # or :flagged or :revealed
    @bomb = false
    @adjacent_tiles = []
    @adjacent_bombs = 0
  end
end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  g.board.tiles
end
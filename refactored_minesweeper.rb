class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

end

class Board
  attr_accessor :tiles

  def initialize
    @tiles = Array.new(9) {Array.new * 9}
    @tiles.each do |row|
      9.times { row << Tile.new }
    end
    place_bombs
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
end

class Tile
  attr_accessor :bomb, :state, :adjacent_tiles, :adjacent_bombs

  def initialize
    @state = :hidden # or :flagged or :revealed
    @bomb = false
    @adjacent_tiles = []
    @adjacent_bombs = 0
  end

  def to_s
    bomb.to_s
  end
end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  p g.board
end
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
        assign_adjacencies(x,y)
      end
    end

    tiles.flatten.each { |tile| tile.find_adjacent_bombs }

    @still_alive = true
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

  def assign_adjacencies(x,y)
    tile = tiles[x][y]
    valid_moves(x,y).each do |pos|
      tile.adjacent_tiles << tiles[pos[0]][pos[1]]
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

  def show_everything
    tiles.each do |row|
      row.each do |tile|
        print "#{tile.adjacent_bombs}, "
      end
      puts
    end
  end

  def select_tile(x, y)
    tile = tiles[x][x]

    if tile.bomb
      tile.state = :revealed
      @still_alive = false
    else
      tile.reveal
    end
  end

  def to_s
    str = String.new
    tiles.each do |row|
      row.each do |tile|
        if tile.state == :revealed
          if tile.adjacent_bombs > 0
            str += "#{tile.adjacent_bombs}, "
          else
            str += "_, "
          end
        else
          str += "*, "
        end
      end
      str += "\n"
    end

    str
  end
end

class Tile
  attr_accessor :bomb, :state, :adjacent_tiles, :adjacent_bombs, :display_value

  def initialize
    @state = :hidden # or :flagged or :revealed
    @bomb = false
    @adjacent_tiles = []
    @adjacent_bombs = 0
    @display_value = {hidden: "*", flagged: "F", revealed: @adjacent_bombs.to_s}
  end

  def find_adjacent_bombs
    self.adjacent_tiles.each do |tile|
      self.adjacent_bombs += 1 if tile.bomb
    end
  end

  def reveal
    # debugger
    return if [:flagged, :revealed].include?(self.state) || self.bomb

    if self.adjacent_bombs > 0
      self.state = :revealed
      return
    end

    self.state = :revealed

    adjacent_tiles.each do |tile|
      tile.reveal
    end
  end

  def to_s
    display_value[state]
  end
end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  g.board.show_everything
  g.board.select_tile(1,1)

  puts g.board

  puts
  g.board.show_everything
end
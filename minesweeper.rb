require 'yaml'

class Minesweeper
  class BadMinesweeperInput < StandardError
  end

  attr_accessor :board

  def initialize
    @board = Board.new
    play
  end

  def play
    puts "Welcome to Minesweeper"
    puts "Save during any turn by typing 'save'"
    puts "Load the last save now by typing 'load' now"
    puts "Otherwise, hit enter to continue"

    input = gets.chomp

    if input == 'load'
      self.board = self.load
    end

    until self.board.over?
      puts board.to_s
      play_move
    end

    if board.won?
      puts "Congratulations!!!111!!!ROFLCOPTERAIRFORCE"
    else
      puts board.to_s
      puts "BOMB! You lose."
    end
  end

  def play_move
    puts "Pick a square (x, y, 'f'): "
    input = gets.strip.downcase

    if input == 'save'
      self.save
      puts "Game saved"
      return
    end

    begin
      y, x, f = parse_input(input)
    rescue BadMinesweeperInput
      puts "Invalid move. Try again:"
      input = gets.strip.downcase
      retry
    end

    if f.nil?
      board.select_tile(x, y)
    else
      board.toggle_flag(x, y)
    end
  end

  def parse_input(input)
    parsed_input = input.split(',').map(&:to_i)
    raise BadMinesweeperInput if parsed_input.size < 2
    raise BadMinesweeperInput unless parsed_input[0].between?(0,8)
    raise BadMinesweeperInput unless parsed_input[1].between?(0,8)

    parsed_input
  end

  def save
    File.open('save.yaml', 'w') do |f|
      f.puts self.board.to_yaml
    end
  end

  def load
    load_data = File.open('./save.yaml')
    YAML::load(load_data)
  end
end

class Board
  attr_accessor :tiles
  attr_reader :still_alive

  MOVES = [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0],[1,1]]

  def initialize
    @tiles = Array.new(9) {Array.new * 9}
    @tiles.each do |row|
      9.times { row << Tile.new }
    end

    place_bombs
    link_tiles

    tiles.flatten.each { |tile| tile.find_adjacent_bombs }

    @still_alive = true
  end

  def link_tiles
    (0..8).each do |x|
      (0..8).each do |y|
        assign_adjacencies(x,y)
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

  def select_tile(x, y)
    tile = tiles[x][y]

    if tile.bomb
      tile.state = :revealed
      @still_alive = false
    else
      tile.reveal
    end
  end

  def toggle_flag(x, y)
    if tiles[x][y].state == :flagged
      tiles[x][y].state = :hidden

    elsif tiles[x][y].state = :hidden
      tiles[x][y].state = :flagged
    end
  end

  def won?
    won = true
    tiles.flatten.each do |tile|
      if !tile.bomb && [:hidden, :flagged].include?(tile.state)
        won = false
      end
    end

    won
  end

  def over?
    won? || !self.still_alive
  end

  def to_s
    str = "|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |\n"
    str += "|   |-----------------------------------|\n"
    tiles.each_with_index do |row, index|
      str += "| #{index} | "
      row.each do |tile|
        if tile.state == :revealed
          if tile.bomb
            str += "B | "
          elsif tile.adjacent_bombs > 0
            str += "#{tile.adjacent_bombs} | "
          else
            str += "_ | "
          end

        elsif tile.state == :hidden
          str += "* | "

        elsif tile.state == :flagged
          str += "F | "
        end
      end
      str = "#{str.strip}\n"
    end

    str.chop
  end

  def show_everything
    str = String.new
    tiles.each do |row|
      row.each do |tile|
        if tile.bomb
          str += "B, "
        elsif tile.adjacent_bombs > 0
          str += "#{tile.adjacent_bombs}, "
        else
          str += "_, "
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
  end

  def find_adjacent_bombs
    self.adjacent_tiles.each do |tile|
      self.adjacent_bombs += 1 if tile.bomb
    end
  end

  def reveal
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
end

if $PROGRAM_NAME == __FILE__
  Minesweeper.new
end
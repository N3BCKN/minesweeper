require 'ruby2d'

GRID = 50
WIDTH = 600
HEIGHT = 800
BACKGROUND_COLOR = '#ffffff'
BLOCK_COLOR = '#eeeeee'


class Board
  attr_accessor :blocks

  def initialize
    @blocks = []
    generate_blocks
    plant_mines
    mined_neighbours
  end 

  def draw
    @blocks.each_with_index do |_, x|
      @blocks[x].each_with_index do |_, y|
        if @blocks[x][y][:mine] == true 
          Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: 'red')
        else 
          Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: 'green')
          Text.new(@blocks[x][y][:mines_nearby], x: x * GRID +  (GRID/3), y: y * GRID + (GRID/3), size: GRID/2, color: 'black')
        end
      end 
    end 
  end


  private
  def generate_blocks
    (WIDTH/GRID).times do |x|
      @blocks << []
      (HEIGHT/GRID).times do |y|
        block = {
          state: 0,
          mine: false,
          mines_nearby: 0
        }
        @blocks[x][y] = block
      end
    end
  end 

  def plant_mines
    mines_to_plant = ((WIDTH/GRID) * (HEIGHT/GRID) * 0.1).floor

    while mines_to_plant > 0
      block_to_mine = @blocks.flatten.sample
      unless block_to_mine[:mine]
        block_to_mine[:mine] = true 
        mines_to_plant -= 1
      end
    end
  end

  def mined_neighbours  
    @blocks.each_with_index do |_, x|
      @blocks[x].each_with_index do |_, y|
        block = @blocks[x][y]
        next if block[:mine]
        block[:mines_nearby] = number_of_mines_nearby(x,y)
      end 
    end 
  end


  def number_of_mines_nearby(x,y)
    mines = 0
    (-1..1).each do |i|
      (-1..1).each do |n|
        next if !(0..12).includes?(x+i) || !(0..16).includes?(y+n)
        # next if x+i < 0 || x+i >= 12 || y+n < 0 || y+n >= 16
        mines += 1 if @blocks[x+i][y+n][:mine]
      end 
    end 
    mines
  end
end 



set width: WIDTH
set height: HEIGHT
set background: BACKGROUND_COLOR
set title: 'minesweeper'



board = Board.new
board.draw 

show
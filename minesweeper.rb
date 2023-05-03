require 'ruby2d'

GRID = 50
WIDTH = 600
HEIGHT = 800
BACKGROUND_COLOR = '#ffffff'
BLOCK_COLOR = '#eeeeee'
DIFFICULTY_LEVEL = 0.1


class Board
  attr_accessor :blocks

  def initialize
    @blocks = []
    @cols = (WIDTH/GRID).floor
    @rows = (HEIGHT/GRID).floor
    @game_over = false
    generate_blocks
    plant_mines
    mined_neighbours
  end 

  def draw
    @blocks.each_with_index do |_, x|
      @blocks[x].each_with_index do |_, y|
        block = @blocks[x][y]

        if block[:revealed] && !block[:mine]
          Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: 'green')
          Text.new(block[:mines_nearby], x: x * GRID +  (GRID/3), y: y * GRID + (GRID/3), size: GRID * 0.55, color: 'black')
        elsif block[:revealed] && block[:mine]
          # Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: 'red')
          Image.new('./images/boom.png',x: x * GRID, y: y * GRID, size: GRID - 1)
        else
          Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: 'blue')
        end
      end 
    end 
  end

  def reveal_block(x,y)
    return if @game_over || @blocks[x][y][:revealed]
    
    @blocks[x][y][:revealed] = true
    
    if @blocks[x][y][:mine]
      reveal_all_mines 
      @game_over = true
    end

    reveal_nearby_blocks_with_zero_bombs(x,y) if @blocks[x][y][:mines_nearby] == 0
  end


  private
  def generate_blocks
    @cols.times do |x|
      @blocks << []
      @rows.times do |y|
        block = {
          revealed: false,
          mine: false,
          mines_nearby: 0
        }
        @blocks[x][y] = block
      end
    end
  end 

  def plant_mines
    mines_to_plant = (@cols * @rows * DIFFICULTY_LEVEL).floor

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
        next if !(0...@cols).include?(x+i) || !(0...@rows).include?(y+n)
        mines += 1 if @blocks[x+i][y+n][:mine]
      end 
    end 
    mines
  end

  def reveal_all_mines
    @blocks.flatten.map{ |b| b[:revealed] = true if b[:mine]}
  end

  def reveal_nearby_blocks_with_zero_bombs(x,y)
    
  end
end 



set width: WIDTH
set height: HEIGHT
set background: BACKGROUND_COLOR
set title: 'minesweeper'



board = Board.new

update do
  clear 
  board.draw 
end

on :mouse_down do |event|
  board.reveal_block(event.x / GRID, event.y / GRID)
end

show
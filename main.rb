# frozen_string_literal: true

require 'js'

# drawing to js canvas
class Canvas
  def initialize(board)
    @board = board
    @canvas = JS.global[:document].getElementById('game')
    @ctx = @canvas.getContext('2d')
    @last_frame = 0

    process(16)
  end

  def process(new_frame)
    update_canvas

    delta = new_frame - @last_frame
    @last_frame = new_frame

    JS.global.requestAnimationFrame { |ts| process(ts.to_i) }
  end

  def update_canvas
    @width = JS.global[:window][:innerWidth].to_i
    @height = JS.global[:window][:innerHeight].to_i
    @canvas[:width] = width
    @canvas[:height] = height
    # puts @width

    draw
  end

  def draw
    # @ctx[:fillStyle] = 'red'
    # @ctx.fillRect(0, 0, @width, @height)

    @board.draw_outline(@ctx, @height, @width)
  end

  attr_reader :width, :height
  attr_accessor :ctx
end

# game board
class Board
  def initialize
    @height = 20
    @width = 10
    @board = Array.new(@width) { Array.new(@height, nil) }
    @board[3][6] = 0
    @piece = Piece.new(0)
  end

  def draw_outline(ctx, screen_height, screen_width)
    tile_size = [screen_height / (@height + 1), screen_width / (@width + 2)].min
    offset_x = (screen_width - tile_size * (@width + 2)) / 2
    offset_y = (screen_height - tile_size * (@height + 1)) / 2

    ctx[:fillStyle] = '#262626'

    @height.times do |y|
      ctx.fillRect(offset_x, offset_y + y * tile_size, tile_size, tile_size)
      ctx.fillRect(offset_x + (@width + 1) * tile_size, offset_y + y * tile_size, tile_size, tile_size)
    end

    (0..@width + 1).each do |x|
      ctx.fillRect(offset_x + x * tile_size, offset_y + @height * tile_size, tile_size, tile_size)
    end
  end

  def draw_board
    @board.each_with_index do |column, y|
      column.each_with_index do |color, x|
        ctx[:fillStyle] = get_color(color)
        ctx.fillRect(offset_x + x * tile_size, offset_y + y * tile_size, tile_size, tile_size)
      end
    end
  end

  def get_color(index)
    {
      -1 => '#262626',
      0 => '#FF3030',
      1 => '#FF8330',
      2 => '#FFD130',
      3 => '#60EC3F',
      4 => '#3FD2EC',
      5 => '#3F53EC',
      6 => '#FF4FE0',
    }[index]
  end
end

class Piece
  def initialize(index)
    @pos[:x] = 4
    @pos[:y] = 0
    @index = index
  end

  attr_reader :pos
end

board = Board.new
_c = Canvas.new(board)
# puts c.width

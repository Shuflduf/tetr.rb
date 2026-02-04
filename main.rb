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
    @ctx[:fillStyle] = 'red'
    @ctx.fillRect(0, 0, @width, @height)
    @ctx[:fillStyle] = 'blue'
    @ctx.fillRect(10, 10, @width - 80, @height - 80)

    @board.draw_outline!(@ctx)
  end

  attr_reader :width, :height
  attr_accessor :ctx
end

# game board
class Board
  @height = 20
  @width = 10

  def initialize
    @board = Array.new(@width, 0) { Array.new(@height, 0) }
  end

  def draw_outline!(ctx)
    # tile_size
    (0..@height).each do |y|
      @ctx[:fillStyle] = 'black'
      ctx.fillRect(3, 3, 50, 50)
    end
  end
end

board = Board.new
_c = Canvas.new(board)
# puts c.width

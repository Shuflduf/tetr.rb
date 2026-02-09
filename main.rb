# frozen_string_literal: true

require 'js'

# drawing to js canvas
class Canvas
  def initialize(board)
    JS.global[:document].querySelector('#loading').remove

    @board = board
    @canvas = JS.global[:document].getElementById('game')
    @ctx = @canvas.getContext('2d')
    @last_frame = 0

    # JS.global[:window].addEventListener('keydown', ->(event) { @board.input(event, true) })
    # JS.global[:window].addEventListener('keyup', ->(event) { @board.input(event, false) })

    process(16)
  end

  def process(new_frame)
    update_canvas

    delta = new_frame - @last_frame
    @last_frame = new_frame
    @board.update(delta)

    JS.global.requestAnimationFrame { |ts| process(ts.to_i) }
  end

  def update_canvas
    @width = JS.global[:window][:innerWidth].to_i
    @height = JS.global[:window][:innerHeight].to_i
    @canvas[:width] = width
    @canvas[:height] = height

    draw
  end

  def draw
    @board.draw(@ctx, @height, @width)
  end

  attr_reader :width, :height
  attr_accessor :ctx
end

SRSTable.load_data

board = Board.new
Canvas.new(board)

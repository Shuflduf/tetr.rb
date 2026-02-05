# frozen_string_literal: true

require 'js'
require 'json'

# drawing to js canvas
class Canvas
  def initialize(board)
    @board = board
    @canvas = JS.global[:document].getElementById('game')
    @ctx = @canvas.getContext('2d')
    @last_frame = 0

    JS.global[:window].addEventListener('keydown', ->(event) { @board.input(event) })

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

# game board
class Board
  def initialize
    @height = 20
    @width = 10
    @board = Array.new(@width) { Array.new(@height, nil) }
    @piece = Piece.new(6, @board)
  end

  def input(event)
    @piece.input(event)
  end

  def update(delta)
    @piece.update(delta)
  end

  def draw(ctx, screen_height, screen_width)
    tile_size = [screen_height / (@height + 1), screen_width / (@width + 2)].min
    offset_x = (screen_width - tile_size * (@width + 2)) / 2
    offset_y = (screen_height - tile_size * (@height + 1)) / 2
    draw_outline(ctx, tile_size, offset_x, offset_y)
    draw_board(ctx, tile_size, offset_x, offset_y)
    draw_piece(ctx, tile_size, offset_x, offset_y)
  end

  def draw_outline(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = '#262626'

    @height.times do |y|
      ctx.fillRect(offset_x, offset_y + y * tile_size, tile_size, tile_size)
      ctx.fillRect(offset_x + (@width + 1) * tile_size, offset_y + y * tile_size, tile_size, tile_size)
    end

    (0..@width + 1).each do |x|
      ctx.fillRect(offset_x + x * tile_size, offset_y + @height * tile_size, tile_size, tile_size)
    end
  end

  def draw_board(ctx, tile_size, offset_x, offset_y)
    @board.each_with_index do |column, y|
      column.each_with_index do |color, x|
        if color
          ctx[:fillStyle] = get_color(color)
          ctx.fillRect(offset_x + x * tile_size, offset_y + y * tile_size, tile_size, tile_size)
        end
      end
    end
  end

  def draw_piece(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = get_color(@piece.index)
    4.times do |i|
      srs_pos = SRSTable['pieces'][@piece.index][@piece.rot][i]
      pos = [srs_pos[0] + @piece.pos[0], srs_pos[1] + @piece.pos[1]]
      ctx.fillRect(offset_x + pos[0] * tile_size, offset_y + pos[1] * tile_size, tile_size, tile_size)
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

# tetromino
class Piece
  GRAVITY_TIME = 1000

  def initialize(index, board)
    @pos = [4, 2]
    @index = index
    @rot = 0
    @board = board

    @gravity_timer = 0
  end

  def update(delta)
    @gravity_timer += delta
    if @gravity_timer > GRAVITY_TIME
      # @pos[1] += 1
      try_move([0, 1])
      @gravity_timer = 0
    end
  end

  def input(event)
    code = event[:code]
    if code == 'KeyA'
      try_move([-1, 0])
      # @pos[0] -= 1
    elsif code == 'KeyD'
      try_move([1, 0])
      # @pos[0] += 1
    elsif code == 'KeyW'
      try_move([0, 1])
      # @pos[1] += 1
    elsif code == 'ArrowRight'
      try_rotate((@rot + 1) % 4)
    elsif code == 'ArrowLeft'
      try_rotate((@rot + 3) % 4)
    end
  end

  def try_move(vec)
    new_piece = clone
    new_piece.pos = [@pos[0], @pos[1]]
    new_piece.pos[0] += vec[0]
    new_piece.pos[1] += vec[1]
    if new_piece.can_exist?
      @pos[0] += vec[0]
      @pos[1] += vec[1]
    end
  end

  def try_rotate(new_rot)
    new_piece = clone
    new_piece.rot = new_rot
    if new_piece.can_exist?
      @rot = new_rot
    end
  end

  def can_exist?
    piece_ref = SRSTable['pieces'][@index][@rot]
    4.times do |i|
      new_pos = [@pos[0] + piece_ref[i][0], @pos[1] + piece_ref[i][1]]
      return false if new_pos[0] <= 0
      # TODO: fix hardcode
      return false if new_pos[0] >= 11
      return false if new_pos[1] >= 20

      board_piece = @board[new_pos[0] - 1][new_pos[1]]
      return false if board_piece
    end
    true
  end

  attr_accessor :pos, :rot
  attr_reader :index
end

# https://gist.github.com/Shuflduf/e5186328dce8ab7d38a16d73971abcee
class SRSTable
  @data = nil

  def self.[](key)
    @data[key]
  end

  def self.load_data
    promise = JS.global.fetch('srs.json')
    response = promise.await
    json_str = response.text.await.to_s
    @data = JSON.parse(json_str)
  end
end

SRSTable.load_data
board = Board.new
_c = Canvas.new(board)
# puts c.width

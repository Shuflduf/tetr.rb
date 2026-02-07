# frozen_string_literal: true

require 'json'

# tetromino
class Piece
  GRAVITY_TIME = 1000
  DAS = 168
  ARR = 33

  def initialize(index, board, inputs)
    @pos = [4, 0]
    @index = index
    @rot = 0
    @board = board

    @gravity_timer = 0
    @ghost = GhostPiece.new(board)
    @ghost.update(self)
    @inputs = inputs
  end

  def update(delta)
    process_inputs!
    @inputs.update(delta)

    @gravity_timer += delta
    if @gravity_timer > GRAVITY_TIME
      return true unless try_move!([0, 1])

      @gravity_timer = 0
    end
    false
  end

  def process_inputs!
    puts @inputs.left_timer if @inputs.left
    if @inputs.left_timer <= 0 && @inputs.left
      puts 'MOVE'
      try_move!([-1, 0])
    end
    if @inputs.right_timer <= 0 && @inputs.right
      try_move!([1, 0])
    end

    if @inputs.rot_right
      try_rotate!((@rot + 1) % 4)
      @inputs.rot_right = false
    elsif @inputs.rot_left
      try_rotate!((@rot + 3) % 4)
      @inputs.rot_left = false
    end
  end

  # def input(event, pressed)
  #   code = event[:code]
  #   if pressed
  #     if code == 'KeyA'
  #       try_move!([-1, 0])
  #     elsif code == 'KeyD'
  #       try_move!([1, 0])
  #     elsif code == 'KeyW'
  #       try_move!([0, 1])
  #     elsif code == 'ArrowRight'
  #       try_rotate!((@rot + 1) % 4)
  #     elsif code == 'ArrowLeft'
  #       try_rotate!((@rot + 3) % 4)
  #     elsif code == 'KeyS'
  #       harddrop!
  #     end
  #   end
  # end

  def try_move!(vec)
    new_piece = clone
    new_piece.pos = [@pos[0], @pos[1]]
    new_piece.pos[0] += vec[0]
    new_piece.pos[1] += vec[1]
    if new_piece.can_exist?
      @pos[0] += vec[0]
      @pos[1] += vec[1]
      @ghost.update(self)
      return true
    end
    false
  end

  def try_rotate!(new_rot)
    new_piece = clone
    new_piece.rot = new_rot
    if new_piece.can_exist?
      @rot = new_rot
    end
    @ghost.update(self)
  end

  def harddrop!
    while try_move!([0, 1])
    end
    @gravity_timer = GRAVITY_TIME
  end

  def can_exist?
    piece_ref = SRSTable['pieces'][@index][@rot]
    4.times do |i|
      new_pos = [@pos[0] + piece_ref[i][0], @pos[1] + piece_ref[i][1]]
      return false if new_pos[0].negative?
      # TODO: fix hardcode
      return false if new_pos[0] >= 10
      return false if new_pos[1] >= 20

      board_piece = @board[new_pos[0]][new_pos[1]]
      return false if board_piece
    end
    true
  end

  def draw(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = Board.get_color(@index)
    4.times do |i|
      srs_pos = SRSTable['pieces'][@index][@rot][i]
      pos = [srs_pos[0] + @pos[0], srs_pos[1] + @pos[1]]
      ctx.fillRect(offset_x + pos[0] * tile_size, offset_y + pos[1] * tile_size, tile_size, tile_size)
    end
    @ghost.draw(ctx, tile_size, offset_x, offset_y)
  end

  attr_accessor :pos, :rot, :inputs
  attr_reader :index
end

# https://gist.github.com/Shuflduf/e5186328dce8ab7d38a16d73971abcee
class SRSTable
  @data = nil

  def self.[](key)
    @data[key]
  end

  def self.load_data
    json_str = JS.global.fetch('srs.json').await.text.await.to_s
    @data = JSON.parse(json_str)
  end
end

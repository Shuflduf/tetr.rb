# frozen_string_literal: true

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
      return true unless try_move([0, 1])

      @gravity_timer = 0
    end
    false
    puts @pos[0]
    # if @pos[1]
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
      return true
    end
    false
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
      return false if new_pos[0].negative?
      # TODO: fix hardcode
      return false if new_pos[0] >= 10
      return false if new_pos[1] >= 20

      board_piece = @board[new_pos[0]][new_pos[1]]
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

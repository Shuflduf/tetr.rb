# frozen_string_literal: true

# ghost
class GhostPiece
  def initialize(board)
    @pos = [0, 0]
    @rot = 0
    @index = 0

    @board = board
  end

  def update(piece)
    @pos = piece.pos.clone
    @rot = piece.rot
    @index = piece.index
    @pos[1] += 1 while can_exist?
    @pos[1] -= 1
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
    ctx[:fillStyle] = "#{Board.get_color(@index)}33"
    4.times do |i|
      srs_pos = SRSTable['pieces'][@index][@rot][i]
      pos = [srs_pos[0] + @pos[0], srs_pos[1] + @pos[1]]
      ctx.fillRect(offset_x + pos[0] * tile_size, offset_y + pos[1] * tile_size, tile_size, tile_size)
    end
  end
end

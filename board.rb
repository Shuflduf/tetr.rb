# frozen_string_literal: true

# game board
class Board
  def initialize
    @height = 20
    @width = 10
    @board = Array.new(@width) { Array.new(@height, nil) }
    @bag = Bag.new
    @piece = Piece.new(@bag.next, @board)
  end

  def input(event, pressed)
    @piece.input(event, pressed)
  end

  def update(delta)
    placed = @piece.update(delta)
    if placed
      add_to_board!
      @piece = Piece.new(@bag.next, @board)
    end
  end

  def draw(ctx, screen_height, screen_width)
    tile_size = [screen_height / (@height + 1), screen_width / (@width + 2)].min
    offset_x = ((screen_width - tile_size * @width) / 2)
    offset_y = (screen_height - tile_size * (@height + 1)) / 2
    draw_outline(ctx, tile_size, offset_x, offset_y)
    draw_board(ctx, tile_size, offset_x, offset_y)
    @piece.draw(ctx, tile_size, offset_x, offset_y)
  end

  def draw_outline(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = '#262626'
    # ctx[:strokeStyle] = '#262626'

    @height.times do |y|
      ctx.fillRect(offset_x - tile_size, offset_y + y * tile_size, tile_size, tile_size)
      ctx.fillRect(offset_x + @width * tile_size, offset_y + y * tile_size, tile_size, tile_size)
    end

    (-1..@width).each do |x|
      ctx.fillRect(offset_x + x * tile_size, offset_y + @height * tile_size, tile_size, tile_size)
    end
  end

  def draw_board(ctx, tile_size, offset_x, offset_y)
    @board.each_with_index do |column, x|
      column.each_with_index do |color, y|
        if color
          ctx[:fillStyle] = Board.get_color(color)
          ctx.fillRect(offset_x + x * tile_size, offset_y + y * tile_size, tile_size, tile_size)
        end
      end
    end
  end

  def self.get_color(index)
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

  def add_to_board!
    piece_ref = SRSTable['pieces'][@piece.index][@piece.rot]
    4.times do |i|
      x = @piece.pos[0] + piece_ref[i][0]
      y = @piece.pos[1] + piece_ref[i][1]
      @board[x][y] = @piece.index
    end
  end
end

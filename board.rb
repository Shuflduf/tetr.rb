# frozen_string_literal: true

# game board
class Board
  def initialize
    @height = 20
    @width = 10
    start!
  end

  # def input(event, pressed)
  #   @piece.input(event, pressed)
  # end

  def update(delta)
    status = @piece.update(delta)
    if status == :placed
      add_to_board!
      try_clear!
      @piece = Piece.new(@bag.next, @board, @piece.inputs)
      @just_held = false
    elsif status == :hold && !@just_held
      if @held.nil?
        @held = @piece.index
        @piece = Piece.new(@bag.next, @board, @piece.inputs)
      else
        t = @held
        @held = @piece.index
        @piece = Piece.new(t, @board, @piece.inputs)
      end
      @just_held = true
    elsif status == :restart
      start!
    end
  end

  def start!
    @board = Array.new(@width) { Array.new(@height, nil) }
    @bag = Bag.new
    @piece = Piece.new(@bag.next, @board, Inputs.new)
    @held = nil
    @just_held = false
  end

  def draw(ctx, screen_height, screen_width)
    tile_size = [screen_height / (@height + 1), screen_width / (@width + 2)].min
    offset_x = ((screen_width - tile_size * @width) / 2)
    offset_y = (screen_height - tile_size * (@height + 1)) / 2
    draw_outline(ctx, tile_size, offset_x, offset_y)
    draw_board(ctx, tile_size, offset_x, offset_y)
    draw_held(ctx, tile_size, offset_x, offset_y)
    draw_next(ctx, tile_size, offset_x, offset_y)
    @piece.draw(ctx, tile_size, offset_x, offset_y)
  end

  def draw_outline(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = '#262626'

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

  def draw_held(ctx, tile_size, offset_x, offset_y)
    return if @held.nil?

    ctx[:fillStyle] = @just_held ? "#{Board.get_color(@held)}33" : Board.get_color(@held)
    offset = [-6, 1]
    SRSTable['pieces'][@held][0].each do |pos|
      ctx.fillRect(
        offset_x + (pos[0] + offset[0]) * tile_size,
        offset_y + (pos[1] + offset[1]) * tile_size, tile_size, tile_size
      )
    end
  end

  def draw_next(ctx, tile_size, offset_x, offset_y)
    offset = [12, 1]
    5.times do |i|
      p = @bag.upcoming[i]
      ctx[:fillStyle] = Board.get_color(p)
      SRSTable['pieces'][p][0].each do |pos|
        ctx.fillRect(
          offset_x + (pos[0] + offset[0]) * tile_size,
          offset_y + (pos[1] + offset[1] + i * 3) * tile_size, tile_size, tile_size
        )
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

  def try_clear!
    lines_to_move_down = []
    (0...20).each do |y|
      y = 19 - y
      row_full = true
      (0...10).each do |x|
        if @board[x][y].nil?
          row_full = false
        end
      end
      lines_to_move_down << y if row_full
    end
    move_down!(lines_to_move_down)
  end

  def move_down!(lines)
    removed = 0
    lines.each do |line|
      (0...line).each do |y|
        y = line - y + removed
        (0...10).each do |x|
          @board[x][y] = @board[x][y - 1]
        end
      end
      removed += 1
    end
  end
end

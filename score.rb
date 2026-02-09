# frozen_string_literal: true

# score
class Score
  def initialize
    @score = 0
    @highscore = 0
  end

  def lines_cleared(num)
    @score += SRSTable['scoring_lines'][num - 1]
  end

  def tspin_full(num)
    @score += SRSTable['scoring_tspin'][num]
  end

  def tspin_mini(num)
    @score += SRSTable['scoring_mini'][num - 1]
  end

  def draw(ctx, tile_size, offset_x, offset_y)
    ctx[:fillStyle] = '#FFFFFF'
    ctx[:font] = '16px "Press Start 2P"'
    ctx.fillText("SCORE: #{@score}", (12 * tile_size) + offset_x - 16, (20 * tile_size) + offset_y)
    ctx.fillText("HIGH: #{@highscore}", (12 * tile_size) + offset_x - 16, (20 * tile_size) + offset_y + 16)
  end
end

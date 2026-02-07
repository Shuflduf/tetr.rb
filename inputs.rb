# frozen_string_literal: true

# inputs
class Inputs
  attr_accessor :rot_left, :rot_right
  attr_reader :left_timer, :right_timer, :softdrop

  def initialize
    JS.global[:window].addEventListener('keydown', ->(event) { keydown(event) })
    JS.global[:window].addEventListener('keyup', ->(event) { keyup(event) })

    @left = false
    @right = false
    @softdrop = false
    @left_timer = 0
    @right_timer = 0

    @rot_left = false
    @rot_right = false
  end

  def update(delta)
    @left_timer += delta
    @right_timer += delta
  end

  def keydown(event)
    return if event[:repeat] == true

    JS.global[:console].log(event)
    code = event[:code]
    puts code
    if code == 'KeyA'
      @left = true
    elsif code == 'KeyD'
      @right = true
    elsif code == 'KeyW'
      @softdrop = true
    elsif code == 'ArrowRight'
      @rot_right = true
    elsif code == 'ArrowLeft'
      @rot_left = true
    end
  end

  def keyup(event)
    code = event[:code]
    # JS.global[:console].log event
    # if event
    if code == 'KeyA'
      @left = false
      @left_timer = 0
    elsif code == 'KeyD'
      @right = false
      @right_timer = 0
    elsif code == 'KeyW'
      @softdrop = true
    end
  end
end

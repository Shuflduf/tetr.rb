# frozen_string_literal: true

# inputs
class Inputs
  attr_accessor :rot_left, :rot_right, :harddrop, :left_timer, :right_timer
  attr_reader :softdrop, :left, :right

  def initialize
    JS.global[:window].addEventListener('keydown', ->(event) { keydown(event) })
    JS.global[:window].addEventListener('keyup', ->(event) { keyup(event) })

    @down = {
      left: 0,
      right: 0,
      softdrop: 0,
    }
    @just_pressed = {
      left: false,
      right: false,
      softdrop: false,
      rot_left: false,
      rot_right: false,
    }
    # @left = false
    # @right = false
    # @softdrop = false
    # @left_timer = 0
    # @right_timer = 0

    # @rot_left = false
    # @rot_right = false
  end

  def update(delta)
    @down[:left] += delta if @down[:left].positive?
    @down[:right] += delta if @down[:right].positive?
    @down[:softdrop] += delta if @down[:softdrop].positive?
  end

  def keydown(event)
    return if event[:repeat] == true

    JS.global[:console].log(event)
    code = event[:code]
    puts code
    if code == 'KeyA'
      @just_pressed[:left] = true
      @down[:left] = 1
    elsif code == 'KeyD'
      @just_pressed[:right] = true
      @down[:right] = 1
    elsif code == 'KeyW'
      @just_pressed[:softdrop] = true
      @down[:softdrop] = 1
    elsif code == 'KeyS'
      @just_pressed[:harddrop] = true
    elsif code == 'ArrowRight'
      @just_pressed[:rot_right] = true
    elsif code == 'ArrowLeft'
      @just_pressed[:rot_left] = true
    end
  end

  def keyup(event)
    code = event[:code]
    # JS.global[:console].log event
    # if event
    if code == 'KeyA'
      @left = false
    elsif code == 'KeyD'
      @right = false
    elsif code == 'KeyW'
      @softdrop = true
    end
  end
end

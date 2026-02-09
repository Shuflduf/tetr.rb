# frozen_string_literal: true

# inputs
class Inputs
  attr_accessor :just_pressed, :down

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
      hold: false,
    }
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
    elsif code == 'ShiftLeft'
      @just_pressed[:hold] = true
    end
  end

  def keyup(event)
    code = event[:code]
    if code == 'KeyA'
      @down[:left] = 0
    elsif code == 'KeyD'
      @down[:right] = 0
    elsif code == 'KeyW'
      @down[:softdrop] = 0
    end
  end
end

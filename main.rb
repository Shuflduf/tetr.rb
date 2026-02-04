require "js"

width = JS.global[:window][:outerWidth].to_i
height = JS.global[:window][:outerHeight].to_i

canvas = JS.global[:document].getElementById('game')
canvas[:width] = width
canvas[:height] = height

ctx = canvas.getContext('2d')

ctx[:fillStyle] = 'red'
ctx.fillRect(0, 0, width, height)
ctx[:fillStyle] = 'blue'
ctx.fillRect(10, 10, width - 80, height - 80)

$last_frame = 0

def process(new_frame)
  delta = new_frame - $last_frame
  $last_frame = new_frame
  # puts delta

  JS.global.requestAnimationFrame { |ts| process(ts.to_i) }
end

process(16)

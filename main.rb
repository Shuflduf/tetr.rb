require "js"

canvas = JS.global[:document].getElementById("game")
ctx = canvas.getContext("2d")
ctx.moveTo(0, 0)
ctx.lineTo(200, 100)
ctx.strokeStyle = "white"
ctx.stroke()
puts ctx

require "js"

width =  JS.global[:window][:innerWidth].to_i
height = JS.global[:window][:innerHeight].to_i

canvas = JS.global[:document].getElementById("game")
canvas[:width] = width
canvas[:height] = height

ctx = canvas.getContext("2d")
ctx[:fillStyle] = "white"
ctx.fillRect(10, 10, width - 20, height - 20)

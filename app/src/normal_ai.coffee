
class NormalAI
  _in_range: false

  constructor: (@game) ->

  update: () ->
    paddle = @game.right_paddle
    ball = @game.ball

    paddle_pos = paddle.position()

    ball_pos = ball.position()
    ball_vel = ball.velocity()

    range = 5.0

    if ball_vel.x > 0 or ball_pos.x > paddle_pos.x - range
      padding = Math.random() * 2.0 + 0.75

      if ball_pos.y > paddle_pos.y + padding
        paddle.endUp()
        paddle.startDown()
      else if ball_pos.y < paddle_pos.y - padding
        paddle.endDown()
        paddle.startUp()
      else
        paddle.endUp()
        paddle.endDown()

    padding = Math.random() * range - 1.5
    if ball_pos.x > paddle_pos.x - padding and not @_in_range
      @_in_range = true
      r = Math.random()
      if r < 0.3
        paddle.endLeft()
        paddle.startRight()
      else if r < 0.6
        paddle.endRight()
        paddle.startLeft()
      else
        paddle.endLeft()
        paddle.endRight()
    else if ball_pos.x < paddle_pos.x - range and  @_in_range
      @_in_range = false
      paddle.endLeft()
      paddle.endRight()

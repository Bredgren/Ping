
class HardAI
  _in_range: false

  constructor: (@game) ->

  update: () ->
    paddle = @game.right_paddle
    ball = @game.ball

    paddle_pos = paddle.position()

    ball_pos = ball.position()
    ball_vel = ball.velocity()

    range = 5.0

    # Moveing toward us
    if ball_vel.x > 0
      y = @_getExpectedY(ball_pos, ball_vel)
      h = settings.HEIGHT / settings.PPM
      y = Math.max(-100, Math.min(100, y))
      while not (0 <= y <= h)
        if y < 0
          y = -y
        else if y > h
          y = 2 * h - y
      padding = Math.random() * 3.0 + 0.5

      if y > paddle_pos.y + padding
        paddle.endUp()
        paddle.startDown()
      else if y < paddle_pos.y - padding
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

  _getExpectedY: (pos, vel) ->
    dir = vel.Copy()
    dir.Normalize()
    s = (settings.WIDTH / settings.PPM - pos.x) / dir.x
    return s * dir.y + pos.y

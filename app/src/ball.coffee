
class Ball
  # pos and vel in pixels
  constructor: (@game, @sprite, @fix_def) ->
    @body_def = new b2Dynamics.b2BodyDef()
    @body_def.type = b2Dynamics.b2Body.b2_dynamicBody
    @body_def.bullet = true

  init: (pos, vel) ->
    @body = @game.world.CreateBody(@body_def)
    @body.CreateFixture(@fix_def)
    f = @body.GetFixtureList().GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BALL
    @body.GetFixtureList().SetFilterData(f)

    b2_x = pos.x / settings.PPM  #
    b2_y = pos.y / settings.PPM  #
    pos = new b2Vec2(b2_x, b2_y)
    @body.SetPosition(pos)

    vel = new b2Vec2(vel.x / settings.PPM, vel.y / settings.PPM)
    @body.SetLinearVelocity(vel)

    @game.game_stage.addChild(@sprite)

  destroy: () ->
    body = @game.world.GetBodyList()
    while body
      if body is @body
        @game.world.DestroyBody(body)
      body = body.GetNext()
    @game.game_stage.removeChild(@sprite)


  update: () ->
    vel = @body.GetLinearVelocity()
    angle = Math.atan(vel.y / vel.x)
    a = settings.BALL.MAX_ANGLE / 180 * Math.PI
    if (Math.abs(angle) > a)
      target_angle = (if angle > 0 then 1 else -1) * a
      dif = target_angle - angle
      x = vel.x * Math.cos(dif) - vel.y * Math.sin(dif)
      y = vel.x * Math.sin(dif) + vel.y * Math.cos(dif)
      vel.x = x
      vel.y = y

    if (Math.abs(vel.x) < settings.BALL.MIN_X_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * settings.BALL.MIN_X_VEL
      @body.SetLinearVelocity(vel)

    @body.SetLinearVelocity(vel)

    # Apply magnus force perpendicular to direction, proportional to spin
    spin = @body.GetAngularVelocity()
    magnus_dir = {x: -vel.y, y: vel.x}
    if spin > 0
      magnus_dir.x *= -1
      magnus_dir.y *= -1
    mag = Math.sqrt(magnus_dir.x * magnus_dir.x + magnus_dir.y * magnus_dir.y)
    magnus_unit = {x: magnus_dir.x / mag, y: magnus_dir.y / mag}
    mag = spin * settings.BALL.MAGNUS_FORCE
    magnus_force = new b2Vec2( magnus_unit.x * mag, magnus_unit.y * mag)
    @body.ApplyForce(magnus_force, @body.GetPosition())

    f = @body.GetFixtureList().GetFilterData()
    c = settings.COLLISION_CATEGORY
    if vel.x > 0
      f.maskBits = c.BOUNDARY | c.PADDLE_R
    else
      f.maskBits = c.BOUNDARY | c.PADDLE_L
    @body.GetFixtureList().SetFilterData(f)

  draw: () ->
    pos = @body.GetPosition()
    rot = @body.GetAngle()
    @sprite.position.x = pos.x * settings.PPM
    @sprite.position.y = pos.y * settings.PPM
    @sprite.rotation = rot

  position: () ->
    return @body.GetPosition()

  velocity: () ->
    return @body.GetLinearVelocity()

  angularVelocity: () ->
    return @body.GetAngularVelocity()
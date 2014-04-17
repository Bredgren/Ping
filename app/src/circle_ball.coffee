
class CircleBall
  RADIUS: 15
  MIN_X_VEL: 20
  MAX_ANGLE: 60 / 180 * Math.PI
  MAGNUS_SCALE: .05

  # pos and vel in pixels
  constructor: (@game, init_pos, init_vel) ->
    g = new PIXI.Graphics()
    g.lineStyle(2, 0xFFFFFF)
    g.drawCircle(0, 0, @RADIUS)
    g.moveTo(0, 0)
    g.lineTo(0, @RADIUS)
    t = g.generateTexture()
    @sprite = new PIXI.Sprite(t)
    @sprite.anchor.x = 0.5
    @sprite.anchor.y = 0.5
    @game.game_stage.addChild(@sprite)

    b2_radius = @RADIUS / settings.PPM  #
    b2_x = init_pos.x / settings.PPM  #
    b2_y = init_pos.y / settings.PPM  #

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.x = b2_x
    bodyDef.position.y = b2_y

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 0.1
    fixDef.friction = 0.5
    fixDef.restitution = 1
    fixDef.shape = new b2Shapes.b2CircleShape(b2_radius)

    @body = @game.world.CreateBody(bodyDef)
    @body.CreateFixture(fixDef)
    f = @body.GetFixtureList().GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BALL
    @body.GetFixtureList().SetFilterData(f)

    vel = new b2Vec2(init_vel.x / settings.PPM, init_vel.y / settings.PPM)
    @body.SetLinearVelocity(vel)

  update: () ->
    vel = @body.GetLinearVelocity()
    angle = Math.atan(vel.y / vel.x)
    if (Math.abs(angle) > @MAX_ANGLE)
      target_angle = (if angle > 0 then 1 else -1) * @MAX_ANGLE
      dif = target_angle - angle
      x = vel.x * Math.cos(dif) - vel.y * Math.sin(dif)
      y = vel.x * Math.sin(dif) + vel.y * Math.cos(dif)
      vel.x = x
      vel.y = y

    if (Math.abs(vel.x) < @MIN_X_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * @MIN_X_VEL
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
    mag = spin * @MAGNUS_SCALE
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

  destroy: () ->
    body = @game.world.GetBodyList()
    while body
      if body is @body
        @game.world.DestroyBody(body)
      body = body.GetNext()
    @game.game_stage.removeChild(@sprite)

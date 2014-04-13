
class CircleBall
  RADIUS: 15
  MIN_X_VEL: 10
  MIN_ANGLE: 45

  # pos and vel in pixels
  constructor: (@game, init_pos, init_vel) ->
    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
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

    vel = new b2Vec2(init_vel.x / settings.PPM, init_vel.y / settings.PPM)
    @body.SetLinearVelocity(vel)

  update: () ->
    vel = @body.GetLinearVelocity()
    if (Math.abs(vel.x) < @MIN_X_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * @MIN_X_VEL
      @body.SetLinearVelocity(vel)
    @body.SetLinearVelocity(vel)
    console.log(Math.atan(vel.y / vel.x) * 180 / Math.PI)

  draw: () ->
    pos = @body.GetPosition()
    rot = @body.GetAngle()
    @sprite.position.x = pos.x * settings.PPM
    @sprite.position.y = pos.y * settings.PPM
    @sprite.rotation = rot

  destroy: () ->
    body = @game.world.GetBodyList()
    while body
      if body is @body
        @game.world.DestroyBody(body)
      body = body.GetNext()
    @game.game_stage.removeChild(@sprite)

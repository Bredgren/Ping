
#_require ./settings

class Paddle
  LENGTH: 75
  WIDTH: 10
  FORCE: 200
  MAX_VEL: 100
  DAMPING_MOVE: 0
  DAMPING_STILL: 5

  buttons:
    up: false
    down: false
    left: false
    right: false

  constructor: (@game, x, start_y=settings.HEIGHT/2) ->
    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, @WIDTH, @LENGTH)
    t = g.generateTexture()
    @sprite = new PIXI.Sprite(t)
    @sprite.anchor.x = 0.5
    @sprite.anchor.y = 0.5
    @game.game_stage.addChild(@sprite)

    b2_width = @WIDTH / settings.PPM
    b2_length = @LENGTH / settings.PPM
    b2_x = x / settings.PPM
    b2_y = start_y / settings.PPM

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.x = b2_x
    bodyDef.position.y = b2_y

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.2
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_width / 2, b2_length / 2)

    @body = @game.world.CreateBody(bodyDef)
    @body.CreateFixture(fixDef)

  position: () ->
    return @body.GetPosition()

  update: () ->
    pos = @body.GetPosition()
    vel = @body.GetLinearVelocity()

    dir = new b2Vec2(0, 0)
    if @buttons.up isnt @buttons.down
      if @buttons.up
        dir = new b2Vec2(0, -1)
      else if @buttons.down
        dir = new b2Vec2(0, 1)

    if @buttons.up or @buttons.down
      @body.SetLinearDamping(@DAMPING_MOVE)
    else
      @body.SetLinearDamping(@DAMPING_STILL)

    dir.Multiply(@FORCE)
    @body.ApplyForce(dir, pos)

    if (Math.abs(vel.x) > @MAX_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * @MAX_VEL
      @body.SetLinearVelocity(vel)

    if (Math.abs(vel.y) > @MAX_VEL)
      vel.y = (if vel.y > 0 then 1 else -1) * @MAX_VEL
      @body.SetLinearVelocity(vel)

  draw: () ->
    pos = @position()
    @sprite.position.x = pos.x * settings.PPM
    @sprite.position.y = pos.y * settings.PPM

  startUp: () ->
    @buttons.up = true

  endUp: () ->
    @buttons.up = false

  startDown: () ->
    @buttons.down = true

  endDown: () ->
    @buttons.down = false
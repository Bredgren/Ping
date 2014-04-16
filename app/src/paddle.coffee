
#_require ./settings

class Paddle
  LENGTH: 75
  WIDTH: 10
  FORCE: 200
  MAX_VEL: 100
  ANGLE: 20
  DAMPING_MOVE: 0
  DAMPING_STILL: 5

  buttons: null

  constructor: (@game, x, start_y=settings.HEIGHT/2) ->
    @buttons =
      up: false
      down: false
      left: false
      right: false

    g = new PIXI.Graphics()
    g.lineStyle(2, 0xFFFFFF)
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
    bodyDef.fixedRotation = true

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.2
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_width / 2, b2_length / 2)

    @paddle_body = @game.world.CreateBody(bodyDef)
    fix = @paddle_body.CreateFixture(fixDef)
    f = fix.GetFilterData()
    if x < settings.WIDTH / 2
      f.categoryBits = settings.COLLISION_CATEGORY.PADDLE_L
    else
      f.categoryBits = settings.COLLISION_CATEGORY.PADDLE_R
    fix.SetFilterData(f)

    fixDef.density = 1
    fixDef.friction = 0.0
    fixDef.restitution = 0.0
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(0.1, 0.1)

    bodyDef.fixedRotation = false
    @anchor_body = @game.world.CreateBody(bodyDef)
    fix = @anchor_body.CreateFixture(fixDef)
    f = fix.GetFilterData()
    f.categoryBits = 0
    fix.SetFilterData(f)

    jointDef = new b2Joints.b2PrismaticJointDef()
    jointDef.Initialize(@game.top_boundary, @anchor_body,
      new b2Vec2(b2_x, 0),
      new b2Vec2(0, 1))
    @game.world.CreateJoint(jointDef)

    jointDef = new b2Joints.b2RevoluteJointDef()
    jointDef.Initialize(@paddle_body, @anchor_body,
      @anchor_body.GetWorldCenter())
    @game.world.CreateJoint(jointDef)

  position: () ->
    return @paddle_body.GetPosition()

  destroy: () ->
    body = @game.world.GetBodyList()
    while body
      if body is @anchor_body or body is @paddle_body
        @game.world.DestroyBody(body)
      body = body.GetNext()
    @game.game_stage.removeChild(@sprite)

  update: () ->
    body = @paddle_body
    pos = body.GetPosition()
    vel = body.GetLinearVelocity()
    spin = body.GetAngularVelocity()

    # Movement
    dir = new b2Vec2(0, 0)
    if @buttons.up isnt @buttons.down
      if @buttons.up
        dir = new b2Vec2(0, -1)
      else if @buttons.down
        dir = new b2Vec2(0, 1)

    if @buttons.up or @buttons.down
      body.SetLinearDamping(@DAMPING_MOVE)
    else
      body.SetLinearDamping(@DAMPING_STILL)

    dir.Multiply(@FORCE)
    body.ApplyForce(dir, pos)

    if (Math.abs(vel.x) > @MAX_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * @MAX_VEL
      body.SetLinearVelocity(vel)

    if (Math.abs(vel.y) > @MAX_VEL)
      vel.y = (if vel.y > 0 then 1 else -1) * @MAX_VEL
      body.SetLinearVelocity(vel)

    # Rotation
    if @buttons.left isnt @buttons.right
      if @buttons.left
        body.SetAngle(-Math.PI / 180 * @ANGLE)
      else if @buttons.right
        body.SetAngle(Math.PI / 180 * @ANGLE)

    if not @buttons.left and not @buttons.right
      body.SetAngle(0)

  draw: () ->
    pos = @position()
    @sprite.position.x = pos.x * settings.PPM
    @sprite.position.y = pos.y * settings.PPM
    rot = @paddle_body.GetAngle()
    @sprite.rotation = rot

  startUp: () ->
    @buttons.up = true

  endUp: () ->
    @buttons.up = false

  startDown: () ->
    @buttons.down = true

  endDown: () ->
    @buttons.down = false

  startLeft: () ->
    @buttons.left = true

  endLeft: () ->
    @buttons.left = false

  startRight: () ->
    @buttons.right = true

  endRight: () ->
    @buttons.right = false
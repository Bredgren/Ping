
#_require ./circle_ball
#_require ./debug_draw
#_require ./paddle
#_require ./settings

class Game
  states:
    MENU: 0
    GAME: 1
    END: 2

  state: null

  left_paddle: null
  right_paddle: null
  ball: null
  time: 0
  time_limit: 60 * 5
  left_score: 0
  right_score: 0

  _loop_time: 0

  constructor: (@stage) ->
    @hud_stage = new PIXI.DisplayObjectContainer()
    @game_stage = new PIXI.DisplayObjectContainer()
    @bg_stage = new PIXI.DisplayObjectContainer()
    @stage.addChild(@bg_stage)
    @stage.addChild(@game_stage)
    @stage.addChild(@hud_stage)

    @hud_graphics = new PIXI.Graphics()
    @hud_stage.addChild(@hud_graphics)

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @begin_text = new PIXI.Text("Press SPACE to begin", style)
    @return_text = new PIXI.Text("Press SPACE to return to menu", style)
    cx = settings.WIDTH / 2
    cy = settings.HEIGHT / 2
    @begin_text.position.x = Math.round(cx - @begin_text.width / 2)
    @begin_text.position.y = Math.round(cy - @begin_text.height / 2)
    @return_text.position.x = Math.round(cx - @return_text.width / 2)
    @return_text.position.y = Math.round(cy - @return_text.height / 2)

    style = {font: "25px Arial", fill: "#FFFFFF"}
    @time_text = new PIXI.Text("", style)
    @time_text.position.x = settings.WIDTH / 2
    @time_text.position.y = 10
    style = {font: "30px Arial", fill: "#FFFFFF"}
    @left_score_text = new PIXI.Text("", style)
    @left_score_text.position.x = settings.WIDTH / 4
    @left_score_text.position.y = 10
    @right_score_text = new PIXI.Text("", style)
    @right_score_text.position.x = 3 * settings.WIDTH / 4
    @right_score_text.position.y = 10

    @world = new b2Dynamics.b2World(new b2Vec2(0, 0), doSleep=false)
    if settings.DEBUG_DRAW
      debug_drawer = new DebugDraw()
      debug_drawer.SetSprite(@hud_graphics)
      debug_drawer.SetDrawScale(1)
      debug_drawer.SetAlpha(1)
      debug_drawer.SetFillAlpha(1)
      debug_drawer.SetLineThickness(1.0)
      debug_drawer.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit |
        b2DebugDraw.e_centerOfMassBit | b2DebugDraw.e_controllerBit |
        b2DebugDraw.e_pairBit | b2DebugDraw.e_aabbBit)
      @world.SetDebugDraw(debug_drawer)

    b2_w = settings.WIDTH / settings.PPM
    b2_h = 1
    offset = b2_h / 2
    b2_x = b2_w / 2
    b2_y = -offset
    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_staticBody
    bodyDef.position.x = b2_x
    bodyDef.position.y = b2_y

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.2
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_w / 2, b2_h / 2)
    @top_boundary = @world.CreateBody(bodyDef)
    fix = @top_boundary.CreateFixture(fixDef)
    f = fix.GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BOUNDARY
    fix.SetFilterData(f)


    bodyDef.position.x = b2_x
    bodyDef.position.y = settings.HEIGHT / settings.PPM + offset  #
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_w / 2, b2_h / 2)
    @bottom_boundary = @world.CreateBody(bodyDef)
    fix = @bottom_boundary.CreateFixture(fixDef)
    f = fix.GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BOUNDARY
    fix.SetFilterData(f)


    b2_w = b2_h
    b2_h = settings.HEIGHT / settings.PPM  #
    b2_x = -offset
    b2_y = b2_h / 2  #

    bodyDef.position.x = b2_x
    bodyDef.position.y = b2_y
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_w / 2, b2_h / 2)
    @left_boundary = @world.CreateBody(bodyDef)
    fix = @left_boundary.CreateFixture(fixDef)
    f = fix.GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BOUNDARY
    fix.SetFilterData(f)

    b2_x = settings.WIDTH / settings.PPM + offset  #
    bodyDef.position.x = b2_x
    bodyDef.position.y = b2_y
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_w / 2, b2_h / 2)
    @right_boundary = @world.CreateBody(bodyDef)
    fix = @right_boundary.CreateFixture(fixDef)
    f = fix.GetFilterData()
    f.categoryBits = settings.COLLISION_CATEGORY.BOUNDARY
    fix.SetFilterData(f)

    @gotoMenu()

  update: () ->
    t = (new Date()).getTime()
    dt = t - @_loop_time
    @_loop_time = t

    if @state is @states.GAME
      @time -= dt / 1000
      @time_text.setText("" + Math.round(@time))
      @time_text.x = settings.WIDTH / 2 - @time_text.width / 2
      if @time <= 0
        @endGame()

      @left_paddle.update()
      @right_paddle.update()
      @ball.update()
      @world.Step(
        settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
      @world.ClearForces()

      @_checkContacts()

  clear: () ->
    @hud_graphics.clear()

  draw: () ->
    if @state is @states.GAME
      @left_paddle.draw()
      @right_paddle.draw()
      @ball.draw()
      if settings.DEBUG_DRAW
        @world.DrawDebugData()

  scoreRight: () ->
    @right_score++
    @right_score_text.setText("" + @right_score)

  scoreLeft: () ->
    @left_score++
    @left_score_text.setText("" + @left_score)

  startGame: () ->
    @state = @states.GAME
    @hud_stage.removeChild(@begin_text)
    @left_paddle = new Paddle(@, settings.PADDLE_X)
    @right_paddle = new Paddle(@, settings.WIDTH - settings.PADDLE_X)
    center = {x: settings.WIDTH / 2, y: settings.HEIGHT / 2}
    vel = {x: -50, y: 0}
    @ball = new CircleBall(@, center, vel)

    @time = @time_limit
    @left_score = 0
    @right_score = 0

    @time_text.setText("" + @time)
    @left_score_text.setText("" + @left_score)
    @right_score_text.setText("" + @right_score)

    @hud_stage.addChild(@time_text)
    @hud_stage.addChild(@left_score_text)
    @hud_stage.addChild(@right_score_text)

  endGame: () ->
    @state = @states.END
    @hud_stage.addChild(@return_text)
    @left_paddle.destroy()
    @right_paddle.destroy()
    @ball.destroy()

  gotoMenu: () ->
    @state = @states.MENU
    @hud_stage.addChild(@begin_text)
    if @return_text in @hud_stage.children
      @hud_stage.removeChild(@return_text)
      @hud_stage.removeChild(@time_text)
      @hud_stage.removeChild(@left_score_text)
      @hud_stage.removeChild(@right_score_text)

  onKeyDown: (key_code) ->
    bindings = settings.BINDINGS
    if @state is @states.GAME
      switch key_code
        when bindings.P1_UP
          @left_paddle.startUp()
        when bindings.P1_DOWN
          @left_paddle.startDown()
        when bindings.P1_LEFT
          @left_paddle.startLeft()
        when bindings.P1_RIGHT
          @left_paddle.startRight()
        when bindings.P2_UP
          @right_paddle.startUp()
        when bindings.P2_DOWN
          @right_paddle.startDown()
        when bindings.P2_LEFT
          @right_paddle.startLeft()
        when bindings.P2_RIGHT
          @right_paddle.startRight()

    if key_code is bindings.START
      switch @state
        when @states.MENU
          @startGame()
        when @states.END
          @gotoMenu()
        when @states.GAME
          @endGame()

  onKeyUp: (key_code) ->
    if @state isnt @states.GAME then return
    bindings = settings.BINDINGS
    switch key_code
      when bindings.P1_UP
        @left_paddle.endUp()
      when bindings.P1_DOWN
        @left_paddle.endDown()
      when bindings.P1_LEFT
        @left_paddle.endLeft()
      when bindings.P1_RIGHT
        @left_paddle.endRight()
      when bindings.P2_UP
        @right_paddle.endUp()
      when bindings.P2_DOWN
        @right_paddle.endDown()
      when bindings.P2_LEFT
        @right_paddle.endLeft()
      when bindings.P2_RIGHT
        @right_paddle.endRight()

  onMouseDown: (button, screen_pos) ->

  onMouseUp: (button, screen_pos) ->

  onMouseMove: (screen_pos) ->

  onMouseWheel: (delta) ->

  _checkContacts: () ->
    contact = @world.GetContactList()
    while contact
      if contact.IsTouching()
        bodyA = contact.GetFixtureA().GetBody()
        bodyB = contact.GetFixtureB().GetBody()
        if bodyA is @ball.body or bodyB is @ball.body
          if bodyA is @left_boundary or bodyB is @left_boundary
            @scoreRight()
          else if bodyA is @right_boundary or bodyB is @right_boundary
            @scoreLeft()
          else if (bodyA is @left_paddle.paddle_body or
                   bodyB is @left_paddle.paddle_body)
            # paddle = @left_paddle.paddle_body
            ball = @ball.body
            # man = new b2Collision.b2WorldManifold()
            # contact.GetWorldManifold(man)
            # vel_p = ball.GetLinearVelocityFromWorldPoint(
            vel = ball.GetLinearVelocity()
            if vel.x > 0
              contact.SetEnabled(false)
          else if (bodyA is @right_paddle.paddle_body or
                   bodyB is @right_paddle.paddle_body)
            ball = @ball.body
            # paddle = @right_paddle.paddle_body
            vel = ball.GetLinearVelocity()
            if vel.x < 0
              contact.SetEnabled(false)

      contact = contact.GetNext()
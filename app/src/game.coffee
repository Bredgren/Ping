
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
    @top_boundary.CreateFixture(fixDef)

    bodyDef.position.x = b2_x
    bodyDef.position.y = settings.HEIGHT / settings.PPM + offset
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(b2_w / 2, b2_h / 2)
    @bottom_boundary = @world.CreateBody(bodyDef)
    @bottom_boundary.CreateFixture(fixDef)

    @left_paddle = new Paddle(@, settings.PADDLE_X)
    @right_paddle = new Paddle(@, settings.WIDTH - settings.PADDLE_X)

    @gotoMenu()

  update: () ->
    @left_paddle.update()
    @right_paddle.update()
    @world.Step(settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
    @world.ClearForces()

  clear: () ->
    @hud_graphics.clear()

  draw: () ->
    @left_paddle.draw()
    @right_paddle.draw()
    if settings.DEBUG_DRAW
      @world.DrawDebugData()

  startGame: () ->
    @state = @states.GAME
    @hud_stage.removeChild(@begin_text)

  endGame: () ->
    @state = @states.END
    @hud_stage.addChild(@return_text)

  gotoMenu: () ->
    @state = @states.MENU
    @hud_stage.addChild(@begin_text)
    if @return_text in @hud_stage.children
      @hud_stage.removeChild(@return_text)

  onKeyDown: (key_code) ->
    bindings = settings.BINDINGS
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
      when bindings.START
        switch @state
          when @states.MENU
            @startGame()
          when @states.END
            @gotoMenu()
          when @states.GAME
            @endGame()

  onKeyUp: (key_code) ->
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

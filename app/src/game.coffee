
#_require ./circle_ball
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
    b2_w = settings.WIDTH / settings.PPM
    b2_h = 1
    offset = b2_h / 2
    b2_x = 0
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
    @world.Step(settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
    @world.ClearForces()

  clear: () ->
    @hud_graphics.clear()

  draw: () ->
    @left_paddle.draw()
    @right_paddle.draw()

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
        console.log('left1')
      when bindings.P1_RIGHT
        console.log('right1')
      when bindings.P2_UP
        console.log('up2')
      when bindings.P2_DOWN
        console.log('down2')
      when bindings.P2_LEFT
        console.log('left2')
      when bindings.P2_RIGHT
        console.log('right2')
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
        console.log('left1')
      when bindings.P1_RIGHT
        console.log('right1')
      when bindings.P2_UP
        console.log('up2')
      when bindings.P2_DOWN
        console.log('down2')
      when bindings.P2_LEFT
        console.log('left2')
      when bindings.P2_RIGHT
        console.log('right2')

  onMouseDown: (button, screen_pos) ->

  onMouseUp: (button, screen_pos) ->

  onMouseMove: (screen_pos) ->

  onMouseWheel: (delta) ->

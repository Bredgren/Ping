
#_require ./circle_ball
#_require ./debug_draw
#_require ./normal_ai
#_require ./paddle
#_require ./settings

class Game
  states:
    MENU: 0
    COUNT_DOWN: 1
    GAME: 2
    END: 3

  state: null

  left_paddle: null
  right_paddle: null
  ball: null
  time: 0
  time_limit: 60 * 2
  left_score: 0
  right_score: 0

  _loop_time: 0
  _count_down: 3

  _player2_type: "human"

  _normal_ai: null
  _hard_ai: null

  GRAD_TIME: 20
  TIME_TEXT_SIZE: 50

  constructor: (@stage) ->
    @hud_stage = new PIXI.DisplayObjectContainer()
    @game_stage = new PIXI.DisplayObjectContainer()
    @bg_stage = new PIXI.DisplayObjectContainer()
    @stage.addChild(@bg_stage)
    @stage.addChild(@game_stage)
    @stage.addChild(@hud_stage)

    @hud_graphics = new PIXI.Graphics()
    @hud_stage.addChild(@hud_graphics)

    cx = settings.WIDTH / 2
    cy = settings.HEIGHT / 2

    style = {font: "100px Arial", fill: "#FFFFFF"}
    @title_text = new PIXI.Text("Ping", style)
    @title_text.position.x = cx - @title_text.width / 2
    @title_text.position.y = cy / 3

    style = {font: "50px Arial", fill: "#FFFFFF"}
    @victor_text = new PIXI.Text("Player 1 Wins!", style)
    @victor_text.position.x = cx - @victor_text.width / 2
    @victor_text.position.y = cy / 3

    @countdown_text = new PIXI.Text("3", style)
    @countdown_text.position.x = cx - @countdown_text.width / 2
    @countdown_text.position.y = cy / 3

    style = {font: "20px Arial", fill: "#FFFFFF"}
    @player1_text = new PIXI.Text("Player 1", style)
    @player1_text.position.x = cx / 3 - @player1_text.width / 2
    @player1_text.position.y = cy / 2

    @player2_text = new PIXI.Text("Player 2", style)
    @player2_text.position.x = settings.WIDTH - cx / 3 - @player2_text.width / 2
    @player2_text.position.y = cy / 2

    @controls1_text = new PIXI.Text("  W\nA S D", style)
    @controls1_text.position.x = Math.round(cx / 3 - @controls1_text.width / 2)
    @controls1_text.position.y = Math.round(cy * 0.75)

    w = 75
    h = 75
    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.moveTo(w / 2, h * 0.4)
    g.lineTo(w / 2, 0)
    g.lineTo(w * 0.4, h * 0.2)
    g.moveTo(w / 2, 0)
    g.lineTo(w * 0.6, h * 0.2)

    g.moveTo(w / 2, h * 0.6)
    g.lineTo(w / 2, h)
    g.lineTo(w * 0.4, h * 0.8)
    g.moveTo(w / 2, h)
    g.lineTo(w * 0.6, h * 0.8)

    g.moveTo(w * 0.4, h / 2)
    g.lineTo(0, h  / 2)
    g.lineTo(w * 0.2, h * 0.4)
    g.moveTo(0, h / 2)
    g.lineTo(w * 0.2, h * 0.6)

    g.moveTo(w * 0.6, h / 2)
    g.lineTo(w, h  / 2)
    g.lineTo(w * 0.8, h * 0.4)
    g.moveTo(w, h / 2)
    g.lineTo(w * 0.8, h * 0.6)

    @controls2 = new PIXI.Sprite(g.generateTexture())
    @controls2.position.x =
      Math.round(settings.WIDTH - cx * 0.6 - @controls2.width / 2)
    @controls2.position.y = Math.round(cy * 0.65)

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("Human", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    human = rt

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("Human", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    human_selected = rt

    @human_box = new PIXI.Sprite(human_selected)
    @human_box.interactive = true
    @human_box.hitArea = new PIXI.Rectangle(0, 0, 75, 25)
    @human_box.selected = true
    @human_box.setSelected = (val) ->
      if val isnt @selected
        if val
          @selected = true
          @setTexture(human_selected)
        else
          @selected = false
          @setTexture(human)
    @human_box.mouseover = (data) ->
      @setTexture(human_selected)
    @human_box.mouseout = (data) ->
      if not @selected
        @setTexture(human)
    @human_box.click = (data) =>
      @ai_norm_box.setSelected(false)
      @ai_hard_box.setSelected(false)
      data.target.setSelected(true)
      @_onSelectHuman()
    x = settings.WIDTH - cx / 3
    y = cy * 0.7
    @human_box.x = Math.round(x - @human_box.width / 2)
    @human_box.y = Math.round(y - @human_box.height / 2)

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("Normal AI", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    ai_norm = rt

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("Normal AI", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    ai_norm_selected = rt

    @ai_norm_box = new PIXI.Sprite(ai_norm)
    @ai_norm_box.interactive = true
    @ai_norm_box.hitArea = new PIXI.Rectangle(0, 0, 75, 25)
    @ai_norm_box.selected = false
    @ai_norm_box.setSelected = (val) ->
      if val isnt @selected
        if val
          @selected = true
          @setTexture(ai_norm_selected)
        else
          @selected = false
          @setTexture(ai_norm)
    @ai_norm_box.mouseover = (data) ->
      @setTexture(ai_norm_selected)
    @ai_norm_box.mouseout = (data) ->
      if not @selected
        @setTexture(ai_norm)
    @ai_norm_box.click = (data) =>
      @human_box.setSelected(false)
      @ai_hard_box.setSelected(false)
      data.target.setSelected(true)
      @_onSelectNormAI()
    x = settings.WIDTH - cx / 3
    y = cy * 0.7 + 25 + 10
    @ai_norm_box.x = Math.round(x - @ai_norm_box.width / 2)
    @ai_norm_box.y = Math.round(y - @ai_norm_box.height / 2)

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("Hard AI", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    ai_hard = rt

    rt = new PIXI.RenderTexture(76, 26)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, 75, 25)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("Hard AI", style)
    t.position.x = 75 / 2 - t.width / 2
    t.position.y = 25 / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    ai_hard_selected = rt

    @ai_hard_box = new PIXI.Sprite(ai_hard)
    @ai_hard_box.interactive = true
    @ai_hard_box.hitArea = new PIXI.Rectangle(0, 0, 75, 25)
    @ai_hard_box.selected = false
    @ai_hard_box.setSelected = (val) ->
      if val isnt @selected
        if val
          @selected = true
          @setTexture(ai_hard_selected)
        else
          @selected = false
          @setTexture(ai_hard)
    @ai_hard_box.mouseover = (data) ->
      @setTexture(ai_hard_selected)
    @ai_hard_box.mouseout = (data) ->
      if not @selected
        @setTexture(ai_hard)
    @ai_hard_box.click = (data) =>
      @human_box.setSelected(false)
      @ai_norm_box.setSelected(false)
      data.target.setSelected(true)
      @_onSelectHardAI()
    x = settings.WIDTH - cx / 3
    y = cy * 0.7 + 2 * (25 + 10)
    @ai_hard_box.x = Math.round(x - @ai_hard_box.width / 2)
    @ai_hard_box.y = Math.round(y - @ai_hard_box.height / 2)

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @begin_text = new PIXI.Text("Press SPACE to begin", style)
    @return_text = new PIXI.Text("Press SPACE to return to menu", style)
    @begin_text.position.x = Math.round(cx - @begin_text.width / 2)
    @begin_text.position.y = Math.round(cy - @begin_text.height / 2)
    @return_text.position.x = Math.round(cx - @return_text.width / 2)
    @return_text.position.y = Math.round(cy - @return_text.height / 2)

    style = {font: "10px Arial", fill: "#FFFFFF"}
    @quit_text = new PIXI.Text("Press ESC to quit", style)
    @quit_text.position.x = Math.round(settings.WIDTH / 2 - @quit_text.width /2)
    @quit_text.position.y = 0

    style = {font: "#{@TIME_TEXT_SIZE}px Arial", fill: "#FFFFFF"}
    @time_text = new PIXI.Text("000", style)
    @time_text.anchor.x = 0.5
    @time_text.anchor.y = 0.5
    @time_text.position.x = settings.WIDTH / 2
    @time_text.position.y = 10 + @time_text.height / 2
    @time_text.scale.x = 0.5
    @time_text.scale.y = 0.5
    style = {font: "30px Arial", fill: "#FFFFFF"}
    @left_score_text = new PIXI.Text("", style)
    @left_score_text.position.x = settings.WIDTH / 4
    @left_score_text.position.y = 10
    @right_score_text = new PIXI.Text("", style)
    @right_score_text.position.x = 3 * settings.WIDTH / 4
    @right_score_text.position.y = 10

    g = new PIXI.Graphics()
    count = 30
    for x in [0...count]
      g.lineStyle(1, 0xFFFFFF, 1 - (x / count))
      g.moveTo(x, 0)
      g.lineTo(x, settings.HEIGHT)
    @score_grad = new PIXI.Sprite(g.generateTexture())
    @score_grad.anchor.x = 11 / @score_grad.width
    @score_grad.anchor.y = 11 / @score_grad.height

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

    @_normal_ai = new NormalAI(@)
    #@_hard_ai = new HardAI(@)

    @gotoMenu()

  update: () ->
    t = (new Date()).getTime()
    dt = t - @_loop_time
    @_loop_time = t

    if @state is @states.COUNT_DOWN
      new_time = @_count_down - dt / 1000
      if ((Math.ceil(new_time) < Math.ceil(@_count_down) or
         @_count_down is 3) and new_time > 0)
        createjs.Sound.play(settings.SOUNDS.START_TIMER.ID)
      @_count_down = new_time
      if @_count_down <= 0
        createjs.Sound.play(settings.SOUNDS.START_BUZZER.ID)
        @state = @states.GAME
        @hud_stage.removeChild(@countdown_text)
      @countdown_text.setText("" + Math.ceil(@_count_down))
    else if @state is @states.GAME
      new_time = @time - dt / 1000
      time = Math.ceil(new_time)
      t = "" + time
      if t.length is 1
        t = "00#{t}"
      else if t.length is 2
        t = "0#{t}"
      @time_text.setText(t)
      if new_time <= 10
        if ((Math.ceil(new_time) < Math.ceil(@time) or
           @time is 10) and new_time > 0)
          createjs.Sound.play(settings.SOUNDS.END_TIMER.ID)
        if new_time <= 0
          createjs.Sound.play(settings.SOUNDS.END_BUZZER.ID)

        decimal = new_time - Math.floor(new_time)
        @time_text.scale.x = decimal + 0.4
        @time_text.scale.y = decimal + 0.4

      @time = new_time

      if @time <= 0
        @endGame()
        return

      @left_paddle.update()
      if @_player2_type is "normal ai"
        @_normal_ai.update()
      if @_player2_type is "hard ai"
        @_normal_ai.update()
        # @_hard_ai.update()
      @right_paddle.update()
      @ball.update()
      @world.Step(
        settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
      @world.ClearForces()

      @_checkContacts()

    if @_score_counter > 0
      @_score_counter--
      @score_grad.alpha = @_score_counter / @GRAD_TIME
      if @_score_counter <= 0
        @hud_stage.removeChild(@score_grad)

  clear: () ->
    @hud_graphics.clear()

  draw: () ->
    if @state is @states.GAME or @state is @states.COUNT_DOWN
      @left_paddle.draw()
      @right_paddle.draw()
      @ball.draw()
      if settings.DEBUG_DRAW
        @world.DrawDebugData()

  scoreRight: () ->
    @right_score++
    @right_score_text.setText("" + @right_score)

    @score_grad.scale.x = 1
    @score_grad.position.x = 0
    @hud_stage.addChild(@score_grad)
    @_score_counter = @GRAD_TIME

  scoreLeft: () ->
    @left_score++
    @left_score_text.setText("" + @left_score)

    @score_grad.scale.x = -1
    @score_grad.position.x = settings.WIDTH
    @hud_stage.addChild(@score_grad)
    @_score_counter = @GRAD_TIME

  startGame: () ->
    @state = @states.COUNT_DOWN
    @_count_down = 3
    @hud_stage.removeChild(@begin_text)
    @hud_stage.removeChild(@title_text)
    @hud_stage.removeChild(@player1_text)
    @hud_stage.removeChild(@player2_text)
    @hud_stage.removeChild(@controls1_text)
    if @controls2 in @hud_stage.children
      @hud_stage.removeChild(@controls2)
    if @human_box in @hud_stage.children
      @hud_stage.removeChild(@human_box)
    if @ai_norm_box in @hud_stage.children
      @hud_stage.removeChild(@ai_norm_box)
    if @ai_hard_box in @hud_stage.children
      @hud_stage.removeChild(@ai_hard_box)

    @hud_stage.addChild(@quit_text)
    @hud_stage.addChild(@countdown_text)

    @left_paddle = new Paddle(@, settings.PADDLE_X)
    @right_paddle = new Paddle(@, settings.WIDTH - settings.PADDLE_X)
    center = {x: settings.WIDTH / 2, y: settings.HEIGHT / 2}
    vel = {x: -50, y: 0}
    @ball = new CircleBall(@, center, vel)

    @time = @time_limit
    @left_score = 0
    @right_score = 0

    t = "" + Math.ceil(@time)
    if t.length is 1
      t = "00#{t}"
    else if t.length is 2
      t = "0#{t}"
    @time_text.setText(t)
    style = {font: "#{@TIME_TEXT_SIZE}px Arial", fill: "#FFFFFF"}
    @time_text.setStyle(style)
    @time_text.position.x = settings.WIDTH / 2
    @time_text.scale.x = 0.5
    @time_text.scale.y = 0.5

    @left_score_text.setText("" + @left_score)
    @right_score_text.setText("" + @right_score)

    @hud_stage.addChild(@time_text)
    @hud_stage.addChild(@left_score_text)
    @hud_stage.addChild(@right_score_text)

  endGame: () ->
    @state = @states.END
    @hud_stage.removeChild(@quit_text)
    if @countdown_text in @hud_stage.children
      @hud_stage.removeChild(@countdown_text)
    @hud_stage.addChild(@return_text)
    if @left_score > @right_score
      @victor_text.setText("Player 1 Wins!")
    else if @left_score < @right_score
      @victor_text.setText("Player 2 Wins!")
    else
      @victor_text.setText("Player 3 Wins?!")
    @hud_stage.addChild(@victor_text)
    @left_paddle.destroy()
    @right_paddle.destroy()
    @ball.destroy()

  gotoMenu: () ->
    @state = @states.MENU
    @hud_stage.addChild(@begin_text)
    @hud_stage.addChild(@title_text)
    @hud_stage.addChild(@player1_text)
    @hud_stage.addChild(@player2_text)
    @hud_stage.addChild(@controls1_text)
    if @_player2_type is "human"
      @hud_stage.addChild(@controls2)
    @hud_stage.addChild(@human_box)
    @hud_stage.addChild(@ai_norm_box)
    @hud_stage.addChild(@ai_hard_box)

    if @return_text in @hud_stage.children
      @hud_stage.removeChild(@return_text)
    if @time_text in @hud_stage.children
      @hud_stage.removeChild(@time_text)
    if @left_score_text in @hud_stage.children
      @hud_stage.removeChild(@left_score_text)
    if @right_score_text in @hud_stage.children
      @hud_stage.removeChild(@right_score_text)
    if @victor_text in @hud_stage.children
      @hud_stage.removeChild(@victor_text)

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
          if @_player2_type is "human"
            @right_paddle.startUp()
        when bindings.P2_DOWN
          if @_player2_type is "human"
            @right_paddle.startDown()
        when bindings.P2_LEFT
          if @_player2_type is "human"
            @right_paddle.startLeft()
        when bindings.P2_RIGHT
          if @_player2_type is "human"
            @right_paddle.startRight()

    if key_code is bindings.START
      switch @state
        when @states.MENU
          @startGame()
        when @states.END
          @gotoMenu()

    if key_code is bindings.END and
       (@state is @states.GAME or @state is @states.COUNT_DOWN)
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
        if @_player2_type is "human"
          @right_paddle.endUp()
      when bindings.P2_DOWN
        if @_player2_type is "human"
          @right_paddle.endDown()
      when bindings.P2_LEFT
        if @_player2_type is "human"
          @right_paddle.endLeft()
      when bindings.P2_RIGHT
        if @_player2_type is "human"
          @right_paddle.endRight()

  onMouseDown: (button, screen_pos) ->

  onMouseUp: (button, screen_pos) ->

  onMouseMove: (screen_pos) ->

  onMouseWheel: (delta) ->

  _onSelectHuman: () ->
    @_player2_type = "human"
    @hud_stage.addChild(@controls2)

  _onSelectNormAI: () ->
    @_player2_type = "normal ai"
    @hud_stage.removeChild(@controls2)

  _onSelectHardAI: () ->
    @_player2_type = "hard ai"
    @hud_stage.removeChild(@controls2)

  _checkContacts: () ->
    contact = @world.GetContactList()
    while contact
      if contact.IsTouching()
        bodyA = contact.GetFixtureA().GetBody()
        bodyB = contact.GetFixtureB().GetBody()
        if bodyA is @ball.body or bodyB is @ball.body
          if bodyA is @left_boundary or bodyB is @left_boundary
            createjs.Sound.play(settings.SOUNDS.SCORE.ID)
            @scoreRight()
          else if bodyA is @right_boundary or bodyB is @right_boundary
            createjs.Sound.play(settings.SOUNDS.SCORE.ID)
            @scoreLeft()
          else if (bodyA is @left_paddle.paddle_body or
                   bodyB is @left_paddle.paddle_body)
            createjs.Sound.play(settings.SOUNDS.PADDLE_CONTACT.ID)
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
            createjs.Sound.play(settings.SOUNDS.PADDLE_CONTACT.ID)
            ball = @ball.body
            # paddle = @right_paddle.paddle_body
            vel = ball.GetLinearVelocity()
            if vel.x < 0
              contact.SetEnabled(false)

      contact = contact.GetNext()
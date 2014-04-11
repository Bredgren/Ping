
#_require ./config

class Game
  states:
    MENU: 0
    GAME: 1
    END: 2

  state: null

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
    @instruction_text = new PIXI.Text("", style)
    cx = settings.WIDTH / 2
    cy = settings.HEIGHT / 2
    @instruction_text.anchor.x = 0.53
    @instruction_text.anchor.y = 0.53
    @instruction_text.position.x = cx
    @instruction_text.position.y = cy

    @gotoMenu()

  update: () ->

  clear: () ->
    @hud_graphics.clear()

  draw: () ->

  startGame: () ->
    @state = @states.GAME
    @hud_stage.removeChild(@instruction_text)

  endGame: () ->
    @state = @states.END
    console.log(@state)
    @_setInstructionText("Press SPACE to return to menu")
    @hud_stage.addChild(@instruction_text)

  gotoMenu: () ->
    @state = @states.MENU
    @_setInstructionText("Press SPACE to begin")
    @hud_stage.addChild(@instruction_text)

  _setInstructionText: (text) ->
    @instruction_text.setText(text)

  onKeyDown: (key_code) ->
    bindings = settings.BINDINGS
    switch key_code
      when bindings.P1_UP
        console.log('up1')
      when bindings.P1_DOWN
        console.log('down1')
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

  onMouseDown: (button, screen_pos) ->

  onMouseUp: (button, screen_pos) ->

  onMouseMove: (screen_pos) ->

  onMouseWheel: (delta) ->

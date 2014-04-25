
#_require ./ball
#_require ./debug_draw
#_require ./hard_ai
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

  play_sfx: true

  ball_type: 0
  balls: []

  _fade_time: 1
  _start_time: 1

  _loop_time: 0
  _count_down: 3

  _player2_type: "human"

  _normal_ai: null
  _hard_ai: null

  _can_score_l: true
  _can_score_r: true

  _wasd_1: true

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

    stat_y = Math.round(settings.HEIGHT * .65)
    padding = 15
    style = {font: "15px Arial", fill: "#FFFFFF"}
    @h_stat_text = new PIXI.Text("Human", style)
    @h_stat_text.position.x = Math.round(.25 * cx + cx - @h_stat_text.width / 2)
    @h_stat_text.position.y = stat_y

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @nai_stat_text = new PIXI.Text("Normal AI", style)
    @nai_stat_text.position.x = Math.round(.5*cx+cx - @nai_stat_text.width / 2)
    @nai_stat_text.position.y = stat_y

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @hai_stat_text = new PIXI.Text("Hard AI", style)
    @hai_stat_text.position.x = Math.round(.75*cx+cx - @hai_stat_text.width / 2)
    @hai_stat_text.position.y = stat_y

    style = {font: "10px Arial", fill: "#FFFFFF"}
    @h_wins_text = new PIXI.Text("Wins:", style)
    @h_wins_text.position.x = @h_stat_text.position.x
    @h_wins_text.position.y = @h_stat_text.position.y + padding + 5

    @h_losses_text = new PIXI.Text("Loses:", style)
    @h_losses_text.position.x = @h_stat_text.position.x
    @h_losses_text.position.y = @h_wins_text.position.y + padding

    @h_ties_text = new PIXI.Text("Ties:", style)
    @h_ties_text.position.x = @h_stat_text.position.x
    @h_ties_text.position.y = @h_losses_text.position.y + padding

    @h_best_text = new PIXI.Text("Best:", style)
    @h_best_text.position.x = @h_stat_text.position.x
    @h_best_text.position.y = @h_ties_text.position.y + padding

    @h_total1_text = new PIXI.Text("Total:", style)
    @h_total1_text.position.x = @h_stat_text.position.x
    @h_total1_text.position.y = @h_best_text.position.y + padding

    @nai_wins_text = new PIXI.Text("Wins:", style)
    @nai_wins_text.position.x = @nai_stat_text.position.x
    @nai_wins_text.position.y = @nai_stat_text.position.y + padding + 5

    @nai_losses_text = new PIXI.Text("Loses:", style)
    @nai_losses_text.position.x = @nai_stat_text.position.x
    @nai_losses_text.position.y = @nai_wins_text.position.y + padding

    @nai_ties_text = new PIXI.Text("Ties:", style)
    @nai_ties_text.position.x = @nai_stat_text.position.x
    @nai_ties_text.position.y = @nai_losses_text.position.y + padding

    @nai_best_text = new PIXI.Text("Best:", style)
    @nai_best_text.position.x = @nai_stat_text.position.x
    @nai_best_text.position.y = @nai_ties_text.position.y + padding

    @nai_total1_text = new PIXI.Text("Total:", style)
    @nai_total1_text.position.x = @nai_stat_text.position.x
    @nai_total1_text.position.y = @nai_best_text.position.y + padding

    @hai_wins_text = new PIXI.Text("Wins:", style)
    @hai_wins_text.position.x = @hai_stat_text.position.x
    @hai_wins_text.position.y = @hai_stat_text.position.y + padding + 5

    @hai_losses_text = new PIXI.Text("Loses:", style)
    @hai_losses_text.position.x = @hai_stat_text.position.x
    @hai_losses_text.position.y = @hai_wins_text.position.y + padding

    @hai_ties_text = new PIXI.Text("Ties:", style)
    @hai_ties_text.position.x = @hai_stat_text.position.x
    @hai_ties_text.position.y = @hai_losses_text.position.y + padding

    @hai_best_text = new PIXI.Text("Best:", style)
    @hai_best_text.position.x = @hai_stat_text.position.x
    @hai_best_text.position.y = @hai_ties_text.position.y + padding

    @hai_total1_text = new PIXI.Text("Total:", style)
    @hai_total1_text.position.x = @hai_stat_text.position.x
    @hai_total1_text.position.y = @hai_best_text.position.y + padding

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

    @controls1 = new PIXI.Sprite.fromImage("assets/img/wasd.png")
    @controls1.position.x = Math.round(cx / 4)
    @controls1.position.y = Math.round(cy * 0.65)

    @controls2 = new PIXI.Sprite.fromImage("assets/img/arrows.png")
    @controls2.position.x = Math.round(settings.WIDTH - cx * 0.6)
    @controls2.position.y = Math.round(cy * 0.65)

    w = 106
    h = 25
    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, w, h)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("Swap Controls", style)
    t.position.x = w / 2 - t.width / 2
    t.position.y = h / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    swap = rt

    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, w, h)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("Swap Controls", style)
    t.position.x = w / 2 - t.width / 2
    t.position.y = h / 2 - t.height / 2
    c.addChild(t)
    rt.render(c)
    swap_selected = rt

    @swap_box = new PIXI.Sprite(swap)
    @swap_box.interactive = true
    @swap_box.hitArea = new PIXI.Rectangle(0, 0, w, h)
    @swap_box.mouseover = (data) ->
      @setTexture(swap_selected)
    @swap_box.mouseout = (data) ->
      @setTexture(swap)
    @swap_box.click = (data) =>
      @_swapControls()
    x = cx / 4 - 13
    y = cy * 0.9
    @swap_box.x = Math.round(x)
    @swap_box.y = Math.round(y)

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

    w = 75
    h = 25
    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, w, h)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("SFX: ON", style)
    t.position.x = Math.round(w / 2 - t.width / 2)
    t.position.y = Math.round(h / 2 - t.height / 2)
    c.addChild(t)
    rt.render(c)
    sfx_on = rt

    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, w, h)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("SFX: ON", style)
    t.position.x = Math.round(w / 2 - t.width / 2)
    t.position.y = Math.round(h / 2 - t.height / 2)
    c.addChild(t)
    rt.render(c)
    sfx_on_hover = rt

    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.lineStyle(1, 0xFFFFFF)
    g.drawRect(0, 0, w, h)
    c.addChild(g)
    style = {font: "15px Arial", fill: "#FFFFFF"}
    t = new PIXI.Text("SFX: OFF", style)
    t.position.x = Math.round(w / 2 - t.width / 2)
    t.position.y = Math.round(h / 2 - t.height / 2)
    c.addChild(t)
    rt.render(c)
    sfx_off = rt

    rt = new PIXI.RenderTexture(w + 1, h + 1)
    c = new PIXI.DisplayObjectContainer()

    g = new PIXI.Graphics()
    g.beginFill(0xFFFFFF)
    g.drawRect(0, 0, w, h)
    g.endFill()
    c.addChild(g)
    style = {font: "15px Arial", fill: "#000000"}
    t = new PIXI.Text("SFX: OFF", style)
    t.position.x = Math.round(w / 2 - t.width / 2)
    t.position.y = Math.round(h / 2 - t.height / 2)
    c.addChild(t)
    rt.render(c)
    sfx_off_hover = rt

    @sfx_box = new PIXI.Sprite(sfx_on)
    @sfx_box.interactive = true
    @sfx_box.hitArea = new PIXI.Rectangle(0, 0, w, h)
    @sfx_box.mouseover = (data) =>
      if @play_sfx
        data.target.setTexture(sfx_on_hover)
      else
        data.target.setTexture(sfx_off_hover)
    @sfx_box.mouseout = (data) =>
      if @play_sfx
        data.target.setTexture(sfx_on)
      else
        data.target.setTexture(sfx_off)
    @sfx_box.click = (data) =>
      @play_sfx = not @play_sfx
      if @play_sfx
        data.target.setTexture(sfx_on_hover)
      else
        data.target.setTexture(sfx_off_hover)
    @sfx_box.x = settings.WIDTH - w - 10
    @sfx_box.y = settings.HEIGHT - h - 10

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

    padding = 10
    margin = 10
    ball_buttons = []
    _polyButton = (x, y, size, sides) =>
      if sides > 2
        poly = @_getPolygon(sides, size  / settings.PPM)
      else
        r = size

      size = (size + padding) * 2

      rt = new PIXI.RenderTexture(size + 1, size + 1)
      c = new PIXI.DisplayObjectContainer()

      g = new PIXI.Graphics()
      g.lineStyle(1, 0xFFFFFF)
      g.drawRect(0, 0, size, size)
      if sides > 2
        @_drawPolygon(poly, g, size / 2, size / 2)  #
      else
        g.lineStyle(2, 0xFFFFFF)
        g.drawCircle(size / 2, size / 2, r)
        g.moveTo(size / 2, size / 2)
        g.lineTo(size / 2 + r, size / 2)
      c.addChild(g)
      rt.render(c)
      button = rt

      rt = new PIXI.RenderTexture(size + 1, size + 1)
      c = new PIXI.DisplayObjectContainer()

      g = new PIXI.Graphics()
      g.beginFill(0xFFFFFF)
      g.drawRect(0, 0, size, size)
      g.endFill()
      if sides > 2
        @_drawPolygon(poly, g, size / 2, size / 2, 0x000000)
      else
        g.lineStyle(2, 0x000000)
        g.drawCircle(size / 2, size / 2, r)
        g.moveTo(size / 2, size / 2)
        g.lineTo(size / 2 + r, size / 2)
      c.addChild(g)
      rt.render(c)
      button_selected = rt

      button_box = new PIXI.Sprite(button)
      button_box.interactive = true
      button_box.hitArea = new PIXI.Rectangle(0, 0, size, size)
      button_box.selected = false
      button_box.setSelected = (val) ->
        if val isnt @selected
          if val
            @selected = true
            @setTexture(button_selected)
          else
            @selected = false
            @setTexture(button)
      button_box.mouseover = (data) ->
        @setTexture(button_selected)
      button_box.mouseout = (data) ->
        if not @selected
          @setTexture(button)
      i = ball_buttons.length
      button_box.click = (data) =>
        b.setSelected(false) for b in ball_buttons
        data.target.setSelected(true)
        @ball_type = i
      button_box.x = Math.round(x - button_box.width / 2)
      button_box.y = Math.round(y - button_box.height / 2)  #
      ball_buttons.push(button_box)

      return button_box

    _lockText = (x, y, size, text, tx=5, ty=5) ->
      size = (size + padding) * 2

      rt = new PIXI.RenderTexture(size + 1, size + 1)
      c = new PIXI.DisplayObjectContainer()

      g = new PIXI.Graphics()
      g.lineStyle(1, 0xFFFFFF)
      g.drawRect(0, 0, size, size)
      c.addChild(g)
      style = {
        font: "9px Arial",
        fill: "#FFFFFF",
        align: 'left',
        wordWrap: true,
        wordWrapWidth: size - tx}
      t = new PIXI.Text(text, style)
      t.position.x = tx
      t.position.y = ty
      c.addChild(t)
      rt.render(c)
      box = rt

      locked_box = new PIXI.Sprite(box)
      locked_box.x = Math.round(x - locked_box.width / 2)  #
      locked_box.y = Math.round(y - locked_box.height / 2)  #

      return locked_box

    x = cx / 4  #
    y = cy * 1.4
    size = settings.BALL.SIZE

    @_cir = _polyButton(x, y, size, 0)
    x += (size + padding) * 2 + margin
    @_oct = _polyButton(x, y, size, 8)
    @_oct_lock = _lockText(x, y, size, "Total > 80 Normal AI")
    x += (size + padding) * 2 + margin
    @_hep = _polyButton(x, y, size, 7)
    @_hep_lock = _lockText(x, y, size, "Complete 7 rounds against AI")
    x += (size + padding) * 2 + margin
    @_hex = _polyButton(x, y, size, 6)
    @_hex_lock = _lockText(x, y, size, "Wins >= 6 Normal AI")
    x = cx / 4
    y += (size + padding) * 2 + margin
    @_pen = _polyButton(x, y, size, 5)
    @_pen_lock = _lockText(x, y, size, "Complete 50 rounds against AI")
    x += (size + padding) * 2 + margin
    @_sqr = _polyButton(x, y, size, 4)
    @_sqr_lock = _lockText(x, y, size, "Score >= 4x Normal AI score")
    x += (size + padding) * 2 + margin
    @_tri = _polyButton(x, y, size, 3)
    @_tri_lock = _lockText(x, y, size, "Wins >= 3 Hard AI")
    x += (size + padding) * 2 + margin
    @_gui = _lockText(x, y, size, "Press H to toggle controls")
    @_gui_lock = _lockText(x, y, size, "Unlock all balls")

    @_cir.setSelected(true)

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

    b2_w = settings.WIDTH / settings.PPM  #
    b2_h = 1
    offset = b2_h / 2  #
    b2_x = b2_w / 2  #
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
    @_hard_ai = new HardAI(@)

    # Circle Ball
    g = new PIXI.Graphics()
    g.lineStyle(2, 0xFFFFFF)
    g.drawCircle(0, 0, settings.BALL.SIZE)
    g.moveTo(0, 0)
    g.lineTo(settings.BALL.SIZE, 0)
    t = g.generateTexture()
    sprite = new PIXI.Sprite(t)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    fix_def = new b2Dynamics.b2FixtureDef()
    fix_def.density = 0.1
    fix_def.friction = 0.5
    fix_def.restitution = 1
    b2_radius = settings.BALL.SIZE / settings.PPM  #
    fix_def.shape = new b2Shapes.b2CircleShape(b2_radius)

    # Circle Ball
    @balls.push(new Ball(@, sprite, fix_def))
    # Octagon Ball
    @balls.push(@_makePolygonBall(8))
    # Heptagon Ball
    @balls.push(@_makePolygonBall(7))
    # Hexagon Ball
    @balls.push(@_makePolygonBall(6))
    # Pentagon Ball
    @balls.push(@_makePolygonBall(5))
    # Square Ball
    @balls.push(@_makePolygonBall(4))
    # Triangle Ball
    @balls.push(@_makePolygonBall(3))

    @gotoMenu()

  _makePolygonBall: (sides) ->
    b2_size = settings.BALL.SIZE / settings.PPM  #
    poly = @_getPolygon(sides, b2_size)
    g = new PIXI.Graphics()
    @_drawPolygon(poly, g)
    t = g.generateTexture()
    sprite = new PIXI.Sprite(t)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    fix_def = new b2Dynamics.b2FixtureDef()
    fix_def.density = 0.1
    fix_def.friction = 0.5
    fix_def.restitution = 1
    fix_def.shape = new b2Shapes.b2PolygonShape.AsArray(poly, sides)

    return new Ball(@, sprite, fix_def)

  _getPolygon: (sides, radius) ->
    TAU = 2 * Math.PI
    step_size = TAU / sides
    v = []
    angle = 0
    while angle < TAU
      x = radius * Math.cos(angle)
      y = radius * Math.sin(angle)
      v.push({x: x, y: y})
      angle += step_size
    return v

  _drawPolygon: (poly, g, x=0, y=0, color=0xFFFFFF) ->
    g.lineStyle(2, color)
    v0 = poly[0]
    g.moveTo(v0.x * settings.PPM + x, v0.y * settings.PPM + y)
    for v in poly[1...]
      g.lineTo(v.x * settings.PPM + x, v.y * settings.PPM + y)
    g.lineTo(v0.x * settings.PPM + x, v0.y * settings.PPM + y)
    g.moveTo(x, y)
    g.lineTo(poly[0].x * settings.PPM + x, poly[0].y * settings.PPM + y)

  update: () ->
    t = (new Date()).getTime()
    dt = t - @_loop_time
    @_loop_time = t

    if dt < 10000
      @_start_time -= dt / 1000
      if @_start_time > 0
        @hud_stage.alpha = 1 - (@_start_time / @_fade_time)
        @game_stage.alpha = 1 - (@_start_time / @_fade_time)
      else
        if @hud_stage.alpha isnt 1
          @hud_stage.alpha = 1
        if @game_stage.alpha isnt 1
          @game_stage.alpha = 1

    if @state is @states.COUNT_DOWN
      new_time = @_count_down - dt / 1000
      if ((Math.ceil(new_time) < Math.ceil(@_count_down) or
         @_count_down is 3) and new_time > 0)
        @_playSound(settings.SOUNDS.START_TIMER.ID)
      @_count_down = new_time
      if @_count_down <= 0
        @_playSound(settings.SOUNDS.START_BUZZER.ID)
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
          @_playSound(settings.SOUNDS.END_TIMER.ID)
        if new_time <= 0
          @_playSound(settings.SOUNDS.END_BUZZER.ID)

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
        @_hard_ai.update()
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
    @hud_stage.removeChild(@controls1)
    @hud_stage.removeChild(@swap_box)

    @hud_stage.removeChild(@h_stat_text)
    @hud_stage.removeChild(@h_wins_text)
    @hud_stage.removeChild(@h_losses_text)
    @hud_stage.removeChild(@h_ties_text)
    @hud_stage.removeChild(@h_best_text)
    @hud_stage.removeChild(@h_total1_text)

    @hud_stage.removeChild(@nai_stat_text)
    @hud_stage.removeChild(@nai_wins_text)
    @hud_stage.removeChild(@nai_losses_text)
    @hud_stage.removeChild(@nai_ties_text)
    @hud_stage.removeChild(@nai_best_text)
    @hud_stage.removeChild(@nai_total1_text)

    @hud_stage.removeChild(@hai_stat_text)
    @hud_stage.removeChild(@hai_wins_text)
    @hud_stage.removeChild(@hai_losses_text)
    @hud_stage.removeChild(@hai_ties_text)
    @hud_stage.removeChild(@hai_best_text)
    @hud_stage.removeChild(@hai_total1_text)

    if @controls2 in @hud_stage.children
      @hud_stage.removeChild(@controls2)
    if @human_box in @hud_stage.children
      @hud_stage.removeChild(@human_box)
    if @ai_norm_box in @hud_stage.children
      @hud_stage.removeChild(@ai_norm_box)
    if @ai_hard_box in @hud_stage.children
      @hud_stage.removeChild(@ai_hard_box)
    if @sfx_box in @hud_stage.children
      @hud_stage.removeChild(@sfx_box)

    @hud_stage.removeChild(@_cir)
    if @_oct in @hud_stage.children
      @hud_stage.removeChild(@_oct)
    if @_oct_lock in @hud_stage.children
      @hud_stage.removeChild(@_oct_lock)

    if @_hep in @hud_stage.children
      @hud_stage.removeChild(@_hep)
    if @_hep_lock in @hud_stage.children
      @hud_stage.removeChild(@_hep_lock)

    if @_hex in @hud_stage.children
      @hud_stage.removeChild(@_hex)
    if @_hex_lock in @hud_stage.children
      @hud_stage.removeChild(@_hex_lock)

    if @_pen in @hud_stage.children
      @hud_stage.removeChild(@_pen)
    if @_pen_lock in @hud_stage.children
      @hud_stage.removeChild(@_pen_lock)

    if @_sqr in @hud_stage.children
      @hud_stage.removeChild(@_sqr)
    if @_sqr_lock in @hud_stage.children
      @hud_stage.removeChild(@_sqr_lock)

    if @_tri in @hud_stage.children
      @hud_stage.removeChild(@_tri)
    if @_tri_lock in @hud_stage.children
      @hud_stage.removeChild(@_tri_lock)

    if @_gui in @hud_stage.children
      @hud_stage.removeChild(@_gui)
    if @_gui_lock in @hud_stage.children
      @hud_stage.removeChild(@_gui_lock)

    @hud_stage.addChild(@quit_text)
    @hud_stage.addChild(@countdown_text)

    @left_paddle = new Paddle(@, settings.PADDLE.X)
    @right_paddle = new Paddle(@, settings.WIDTH - settings.PADDLE.X)
    center = {x: settings.WIDTH / 2, y: settings.HEIGHT / 2}
    vel = {x: -50, y: 0}
    @ball = @balls[@ball_type]
    @ball.init(center, vel)

    @time = @time_limit
    @left_score = 0
    @right_score = 0

    @_can_score_l = true
    @_can_score_r = true

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

    @_start_time = @_fade_time

  endGame: (quit=false) ->
    @state = @states.END
    @hud_stage.removeChild(@quit_text)
    if @countdown_text in @hud_stage.children
      @hud_stage.removeChild(@countdown_text)
    @hud_stage.addChild(@return_text)
    key = @_player2_type
    dim = "Human"
    if @_player2_type is "normal ai"
      dim = "Normal AI"
    else if @_player2_type is "hard ai"
      dim = "Hard AI"
    if quit
      @victor_text.setText("  No one wins!")
      key += " quits"
      ga('send', {
        'hitType': 'event',
        'eventCategory': dim,
        'eventAction': 'Quit',
        'dimension1': dim,
        'metric4', 1
      })
    else if @left_score > @right_score
      @victor_text.setText("Player 1 Wins!")
      key += " wins"
      ga('send', {
        'hitType': 'event',
        'eventCategory': dim,
        'eventAction': 'Win',
        'dimension1': dim,
        'metric1', 1
      })
    else if @left_score < @right_score
      @victor_text.setText("Player 2 Wins!")
      key += " losses"
      ga('send', {
        'hitType': 'event',
        'eventCategory': dim,
        'eventAction': 'Loose',
        'dimension1': dim,
        'metric2', 1
      })
    else
      @victor_text.setText("Player 3 Wins?!")
      key += " ties"
      ga('send', {
        'hitType': 'event',
        'eventCategory': dim,
        'eventAction': 'Tie',
        'dimension1': dim,
        'metric3', 1
      })
    @_incSaveItem(key)
    if not quit
      key = @_player2_type + " total 1"
      @_incSaveItem(key, @left_score)
      key = @_player2_type + " total 2"
      @_incSaveItem(key, @right_score)
      key = @_player2_type + " best"
      best = @_getSaveItemInt(key)
      if @left_score > best
        @_setSaveItem(key, @left_score)
    @hud_stage.addChild(@victor_text)
    @left_paddle.destroy()
    @right_paddle.destroy()
    @ball.destroy()

    # Check unlocks
    if @_getSaveItemInt("normal ai total 1") > 80
      @_setSaveItem("oct", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Octagon',
        'eventAction': 'Unlock',
        'dimension2': 'Octagon',
        'metric5', 1
      })

    completed = 0
    completed += @_getSaveItemInt("normal ai wins")
    completed += @_getSaveItemInt("normal ai losses")
    completed += @_getSaveItemInt("normal ai ties")
    completed += @_getSaveItemInt("hard ai wins")
    completed += @_getSaveItemInt("hard ai losses")
    completed += @_getSaveItemInt("hard ai ties")
    if completed > 7
      @_setSaveItem("hep", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Heptagon',
        'eventAction': 'Unlock',
        'dimension2': 'Heptagon',
        'metric5', 1
      })

    if @_getSaveItemInt("normal ai wins") >= 6
      @_setSaveItem("hex", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Hexagon',
        'eventAction': 'Unlock',
        'dimension2': 'Hexagon',
        'metric5', 1
      })

    if completed > 50
      @_setSaveItem("pen", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Pentagon',
        'eventAction': 'Unlock',
        'dimension2': 'Pentagon',
        'metric5', 1
      })

    if @left_score >= 4 * Math.max(@right_score, 1)
      @_setSaveItem("sqr", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Square',
        'eventAction': 'Unlock',
        'dimension2': 'Square',
        'metric5', 1
      })

    if @_getSaveItemInt("hard ai wins") >= 3
      @_setSaveItem("tri", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'Triangle',
        'eventAction': 'Unlock',
        'dimension2': 'Triangle',
        'metric5', 1
      })

    unlocked = 0
    unlocked += @_getSaveItemInt("oct")
    unlocked += @_getSaveItemInt("hep")
    unlocked += @_getSaveItemInt("hex")
    unlocked += @_getSaveItemInt("pen")
    unlocked += @_getSaveItemInt("sqr")
    unlocked += @_getSaveItemInt("tri")
    if unlocked is 6
      @_setSaveItem("gui", 1)
      ga('send', {
        'hitType': 'event',
        'eventCategory': 'GUI',
        'eventAction': 'Unlock',
        'dimension2': 'GUI',
        'metric5', 1
      })

  gotoMenu: () ->
    @state = @states.MENU
    @hud_stage.addChild(@begin_text)
    @hud_stage.addChild(@title_text)
    @hud_stage.addChild(@player1_text)
    @hud_stage.addChild(@player2_text)
    @hud_stage.addChild(@controls1)
    if @_player2_type is "human"
      @hud_stage.addChild(@controls2)
    @hud_stage.addChild(@swap_box)
    @hud_stage.addChild(@human_box)
    @hud_stage.addChild(@ai_norm_box)
    @hud_stage.addChild(@ai_hard_box)
    @hud_stage.addChild(@sfx_box)

    @hud_stage.addChild(@h_stat_text)

    w = @_getSaveItemInt("human wins")
    @h_wins_text.setText("Wins: #{w}")
    @hud_stage.addChild(@h_wins_text)

    l = @_getSaveItemInt("human losses")
    @h_losses_text.setText("Losses: #{l}")
    @hud_stage.addChild(@h_losses_text)

    t = @_getSaveItemInt("human ties")
    @h_ties_text.setText("Ties: #{t}")
    @hud_stage.addChild(@h_ties_text)

    t = @_getSaveItemInt("human best")
    @h_best_text.setText("Best: #{t}")
    @hud_stage.addChild(@h_best_text)

    t = @_getSaveItemInt("human total 1")
    @h_total1_text.setText("Total: #{t}")
    @hud_stage.addChild(@h_total1_text)

    @hud_stage.addChild(@nai_stat_text)

    w = @_getSaveItemInt("normal ai wins")
    @nai_wins_text.setText("Wins: #{w}")
    @hud_stage.addChild(@nai_wins_text)

    l = @_getSaveItemInt("normal ai losses")
    @nai_losses_text.setText("Losses: #{l}")
    @hud_stage.addChild(@nai_losses_text)

    t = @_getSaveItemInt("normal ai ties")
    @nai_ties_text.setText("Ties: #{t}")
    @hud_stage.addChild(@nai_ties_text)

    t = @_getSaveItemInt("normal ai best")
    @nai_best_text.setText("Best: #{t}")
    @hud_stage.addChild(@nai_best_text)

    t = @_getSaveItemInt("normal ai total 1")
    @nai_total1_text.setText("Total: #{t}")
    @hud_stage.addChild(@nai_total1_text)

    @hud_stage.addChild(@hai_stat_text)

    w = @_getSaveItemInt("hard ai wins")
    @hai_wins_text.setText("Wins: #{w}")
    @hud_stage.addChild(@hai_wins_text)

    l = @_getSaveItemInt("hard ai losses")
    @hai_losses_text.setText("Losses: #{l}")
    @hud_stage.addChild(@hai_losses_text)

    t = @_getSaveItemInt("hard ai ties")
    @hai_ties_text.setText("Ties: #{t}")
    @hud_stage.addChild(@hai_ties_text)

    t = @_getSaveItemInt("hard ai best")
    @hai_best_text.setText("Best: #{t}")
    @hud_stage.addChild(@hai_best_text)

    t = @_getSaveItemInt("hard ai total 1")
    @hai_total1_text.setText("Total: #{t}")
    @hud_stage.addChild(@hai_total1_text)

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

    @hud_stage.addChild(@_cir)
    if @_getSaveItemInt('oct') is 1
      @hud_stage.addChild(@_oct)
    else
      @hud_stage.addChild(@_oct_lock)

    if @_getSaveItemInt('hep') is 1
      @hud_stage.addChild(@_hep)
    else
      @hud_stage.addChild(@_hep_lock)

    if @_getSaveItemInt('hex') is 1
      @hud_stage.addChild(@_hex)
    else
      @hud_stage.addChild(@_hex_lock)

    if @_getSaveItemInt('pen') is 1
      @hud_stage.addChild(@_pen)
    else
      @hud_stage.addChild(@_pen_lock)

    if @_getSaveItemInt('sqr') is 1
      @hud_stage.addChild(@_sqr)
    else
      @hud_stage.addChild(@_sqr_lock)

    if @_getSaveItemInt('tri') is 1
      @hud_stage.addChild(@_tri)
    else
      @hud_stage.addChild(@_tri_lock)

    if @_getSaveItemInt('gui') is 1
      @hud_stage.addChild(@_gui)
    else
      @hud_stage.addChild(@_gui_lock)

    @_start_time = @_fade_time

  onKeyDown: (key_code) ->
    bindings = settings.BINDINGS
    if @state is @states.GAME
      switch key_code
        when bindings.P1_UP
          if @_wasd_1
            @left_paddle.startUp()
          else if @_player2_type is "human"
            @right_paddle.startUp()
        when bindings.P1_DOWN
          if @_wasd_1
            @left_paddle.startDown()
          else if @_player2_type is "human"
            @right_paddle.startDown()
        when bindings.P1_LEFT
          if @_wasd_1
            @left_paddle.startLeft()
          else if @_player2_type is "human"
            @right_paddle.startLeft()
        when bindings.P1_RIGHT
          if @_wasd_1
            @left_paddle.startRight()
          else if @_player2_type is "human"
            @right_paddle.startRight()
        when bindings.P2_UP
          if @_wasd_1 and @_player2_type is "human"
            @right_paddle.startUp()
          else
            @left_paddle.startUp()
        when bindings.P2_DOWN
          if @_wasd_1 and @_player2_type is "human"
            @right_paddle.startDown()
          else
            @left_paddle.startDown()
        when bindings.P2_LEFT
          if @_wasd_1 and @_player2_type is "human"
            @right_paddle.startLeft()
          else
            @left_paddle.startLeft()
        when bindings.P2_RIGHT
          if @_wasd_1 and @_player2_type is "human"
            @right_paddle.startRight()
          else
            @left_paddle.startRight()

    if key_code is bindings.START
      switch @state
        when @states.MENU
          @startGame()
        when @states.END
          @gotoMenu()

    if key_code is bindings.END and
       (@state is @states.GAME or @state is @states.COUNT_DOWN)
      @endGame(true)

  onKeyUp: (key_code) ->
    if @state isnt @states.GAME then return
    bindings = settings.BINDINGS
    switch key_code
      when bindings.P1_UP
        if @_wasd_1
          @left_paddle.endUp()
        else if @_player2_type is "human"
          @right_paddle.endUp()
      when bindings.P1_DOWN
        if @_wasd_1
          @left_paddle.endDown()
        else if @_player2_type is "human"
          @right_paddle.endDown()
      when bindings.P1_LEFT
        if @_wasd_1
          @left_paddle.endLeft()
        else if @_player2_type is "human"
          @right_paddle.endLeft()
      when bindings.P1_RIGHT
        if @_wasd_1
          @left_paddle.endRight()
        else if @_player2_type is "human"
          @right_paddle.endRight()
      when bindings.P2_UP
        if @_wasd_1 and @_player2_type is "human"
          @right_paddle.endUp()
        else
          @left_paddle.endUp()
      when bindings.P2_DOWN
        if @_wasd_1 and @_player2_type is "human"
          @right_paddle.endDown()
        else
          @left_paddle.endDown()
      when bindings.P2_LEFT
        if @_wasd_1 and @_player2_type is "human"
          @right_paddle.endLeft()
        else
          @left_paddle.endLeft()
      when bindings.P2_RIGHT
        if @_wasd_1 and @_player2_type is "human"
          @right_paddle.endRight()
        else
          @left_paddle.endRight()

  onMouseDown: (button, screen_pos) ->

  onMouseUp: (button, screen_pos) ->

  onMouseMove: (screen_pos) ->

  onMouseWheel: (delta) ->

  _onSelectHuman: () ->
    @_player2_type = "human"
    @hud_stage.addChild(@controls2)

  _onSelectNormAI: () ->
    @_player2_type = "normal ai"
    if @controls2 in @hud_stage.children
      @hud_stage.removeChild(@controls2)

  _onSelectHardAI: () ->
    @_player2_type = "hard ai"
    if @controls2 in @hud_stage.children
      @hud_stage.removeChild(@controls2)

  _checkContacts: () ->
    contact = @world.GetContactList()
    while contact
      if contact.IsTouching()
        bodyA = contact.GetFixtureA().GetBody()
        bodyB = contact.GetFixtureB().GetBody()
        if bodyA is @ball.body or bodyB is @ball.body
          if @_can_score_r and
             (bodyA is @left_boundary or bodyB is @left_boundary)
            @_playSound(settings.SOUNDS.SCORE.ID)
            @scoreRight()
            @_can_score_r = false
            @_can_score_l = true
          else if @_can_score_l and
                  (bodyA is @right_boundary or bodyB is @right_boundary)
            @_playSound(settings.SOUNDS.SCORE.ID)
            @scoreLeft()
            @_can_score_l = false
            @_can_score_r = true
          else if (bodyA is @left_paddle.paddle_body or
                   bodyB is @left_paddle.paddle_body)
            ball_pos = @ball.position()
            paddle_pos = @left_paddle.position()
            if ball_pos.x > paddle_pos.x
              @_playSound(settings.SOUNDS.PADDLE_CONTACT.ID)
            @_can_score_l = true
          else if (bodyA is @right_paddle.paddle_body or
                   bodyB is @right_paddle.paddle_body)
            ball_pos = @ball.position()
            paddle_pos = @right_paddle.position()
            if ball_pos.x < paddle_pos.x
              @_playSound(settings.SOUNDS.PADDLE_CONTACT.ID)
            @_can_score_r = true

      contact = contact.GetNext()

  _playSound: (id) ->
    if @play_sfx
      createjs.Sound.play(id)

  _incSaveItem: (key, amount=1) ->
    prev = localStorage[key]
    if not prev
      prev = "0"
    localStorage[key] = parseInt(prev) + amount

  _setSaveItem: (key, val) ->
    localStorage[key] = val

  _getSaveItemInt: (key) ->
    val = localStorage[key]
    if not val
      val = "0"
    return parseInt(val)

  _swapControls: () ->
    @_wasd_1 = not @_wasd_1
    x = @controls1.position.x
    @controls1.position.x = @controls2.position.x
    @controls2.position.x = x

    visible_1 = @controls1 in @hud_stage.children
    visible_2 = @controls2 in @hud_stage.children

    if not visible_1 and visible_2
      @hud_stage.addChild(@controls1)
      @hud_stage.removeChild(@controls2)
    else if visible_1 and not visible_2
      @hud_stage.addChild(@controls2)
      @hud_stage.removeChild(@controls1)

    c = @controls1
    @controls1 = @controls2
    @controls2 = c

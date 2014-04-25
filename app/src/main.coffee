# The main script for the game

#_require ./game
#_require ./settings

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  if not createjs.Sound.initializeDefaultPlugins()
    console.log("Couldn't load sound")
    main()  # play with no sound
  else
    manifest = []
    for sound of settings.SOUNDS
      manifest.push({
        id: settings.SOUNDS[sound].ID,
        src: settings.SOUNDS[sound].SRC})

    count = 0
    createjs.Sound.addEventListener("fileload", (event) ->
      count++
      if count is manifest.length
        main())
    createjs.Sound.setVolume(0.3)
    createjs.Sound.registerManifest(manifest, settings.AUDIO_PATH)

W = settings.WIDTH
H = settings.HEIGHT

# The main method for the game
main = ->
  toggle = $("div#toggle-comments")
  toggle.text("Show comments")
  c = $("div.fb-comments")
  c.hide()
  toggle.click(() ->
    console.log('click')
    if c.is(":hidden")
      c.slideDown("slow", () ->
        toggle.text("Hide comments")
      )
    else
      c.slideUp("slow", () ->
        toggle.text("Show comments")
      )
  )

  game_div = $('#game')

  container = $('<div>')
  container.css('margin-right', 'auto')
  container.css('margin-left', 'auto')
  container.css('width', "#{W}px")
  container.css('height', "#{H}px")
  if navigator.userAgent.indexOf("Chrome") > 0
    $('div#browser').remove()
  game_div.append(container)
  game_div.css('width', "#{W}px")
  game_div.css('height', "#{H}px")
  game_div.css('margin', "auto")

  black = 0x000000
  stage = new PIXI.Stage(black)
  renderer = PIXI.autoDetectRenderer(W, H)

  container.append(renderer.view)

  canvas = $('canvas')[0]

  game = new Game(stage)

  gui = new dat.GUI()
  dat.GUI.toggleHide()
  gui.close()
  paddle_folder = gui.addFolder('Paddle')
  paddle_folder.add(settings.PADDLE, 'MOVE_FORCE')
  paddle_folder.add(settings.PADDLE, 'MAX_VEL')
  paddle_folder.add(settings.PADDLE, 'ANGLE')
  paddle_folder.add(settings.PADDLE, 'DAMPING_MOVE')
  paddle_folder.add(settings.PADDLE, 'DAMPING_STILL')
  ball_folder = gui.addFolder('Ball')
  ball_folder.add(settings.BALL, 'MIN_X_VEL')
  ball_folder.add(settings.BALL, 'MAX_ANGLE')
  ball_folder.add(settings.BALL, 'MAGNUS_FORCE')

  ##############################################################################
  # Set event handlers

  onResize = ->
    log_input("resize")

  keyDownListener = (e) ->
    log_input("key down:", e.keyCode)
    game.onKeyDown(e.keyCode)
    if e.keyCode is 32 or 37 <= e.keyCode <= 40
      e.preventDefault()

  keyUpListener = (e) ->
    log_input("key up:", e.keyCode)
    game.onKeyUp(e.keyCode)

  # Catch accidental leaving
  onBeforeUnload = (e) ->
    log_input("leaving")

    # if (not e)
    #   e = window.event
    # e.cancelBubble = true
    # if (e.stopPropagation)
    #   e.stopPropagation()
    #   e.preventDefault()
    #   return "Warning: Progress my be lost."
    # return null

  mouseMoveHandler = (e) ->
    x = e.layerX
    y = e.layerY
    log_input("mouse:", x, y)
    game.onMouseMove({x: x, y: y})

  clickHandler = (e) ->
    x = e.layerX
    y = e.layerY
    log_input("click:", x, y)

  contextMenuHandler = (e) ->
    log_input("context menu")
    return false

  mouseDownHandler = (e) ->
    log_input("mouse down")
    x = e.layerX
    y = e.layerY
    game.onMouseDown(e.button, {x: x, y: y})

  mouseUpHandler = (e) ->
    log_input("mouse up")
    x = e.layerX
    y = e.layerY
    game.onMouseUp(e.button, {x: x, y: y})

  mouseOutHandler = (e) ->
    log_input("mouse out")

  mouseWheelHandler = (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    log_input("mouse wheel: ", delta)

  focusHandler = (e) ->
    log_input("focus")

  blurHandler = (e) ->
    log_input("blur")

  event_catcher = canvas

  window.onresize = onResize
  document.body.addEventListener('keydown', keyDownListener, false)
  document.body.addEventListener('keyup', keyUpListener, false)
  # event_catcher.addEventListener('keydown', keyDownListener, false)
  # event_catcher.addEventListener('keyup', keyUpListener, false)
  window.onbeforeunload = onBeforeUnload
  event_catcher.addEventListener('mousemove', mouseMoveHandler, false)
  event_catcher.addEventListener('click', clickHandler, false)
  event_catcher.oncontextmenu = contextMenuHandler
  event_catcher.addEventListener('mousedown', mouseDownHandler, false)
  event_catcher.addEventListener('mouseup', mouseUpHandler, false)
  event_catcher.addEventListener('mouseout', mouseOutHandler, false)
  event_catcher.addEventListener('DOMMouseScroll', mouseWheelHandler, false)
  event_catcher.addEventListener('mousewheel', mouseWheelHandler, false)
  event_catcher.addEventListener('focus', focusHandler, false)
  event_catcher.addEventListener('blur', blurHandler, false)

  ##############################################################################
  # Game loop

  main_loop = ->
    update()
    clear()
    draw()
    queue()

  update = ->
    game.update()

  clear = ->
    game.clear()

  draw = ->
    game.draw()
    renderer.render(stage)

  queue = ->
    window.requestAnimationFrame(main_loop)

  main_loop()

log_input = (args...) ->
  if settings.PRINT_INPUT
    console.log(args...)
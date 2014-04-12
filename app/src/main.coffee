# The main script for the game

#_require ./game
#_require ./settings

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  # assets = []
  # loader = new PIXI.AssetLoader(assets)
  # loader.onComplete = main
  # loader.load()
  main()

W = settings.WIDTH
H = settings.HEIGHT

# The main method for the game
main = ->
  body = $('body')

  container = $('<div>')
  container.css('margin-right', 'auto')
  container.css('margin-left', 'auto')
  container.css('width', "#{W}px")
  body.append(container)

  black = 0x000000
  stage = new PIXI.Stage(black)
  renderer = PIXI.autoDetectRenderer(W, H)

  container.append(renderer.view)

  canvas = $('canvas')[0]

  game = new Game(stage)

  ##############################################################################
  # Set event handlers

  onResize = ->
    log_input("resize")

  keyDownListener = (e) ->
    log_input("key down:", e.keyCode)
    game.onKeyDown(e.keyCode)

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
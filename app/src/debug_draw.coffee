
#_require ./settings

class DebugDraw extends b2Dynamics.b2DebugDraw

  constructor: () ->
    @_line_width = 1
    @_alpha = 0.5
    @_fill_alpha = 0.5
    @m_sprite = {graphics: {clear: () -> }}

  _worldToScreen: (pos) ->
    return {x: pos.x * settings.PPM, y: pos.y * settings.PPM}

  SetSprite: (@_graphics) ->

  GetSprite: () ->
    return @_graphics

  DrawCircle: (center, radius, color) ->
    @_graphics.alpha = @_alpha
    @_graphics.lineStyle(@_line_width, color.color)
    center = @_worldToScreen(center)
    @_graphics.drawCircle(center.x, center.y, radius * settings.PPM)

  DrawPolygon: (vertices, vertexCount, color) ->
    @_graphics.lineStyle(@_line_width, color.color)
    @_graphics.alpha = @_alpha
    v0 = vertices[0]
    v0 = @_worldToScreen(v0)
    @_graphics.moveTo(v0.x, v0.y)
    for v in vertices[1..]
      v = @_worldToScreen(v)
      @_graphics.lineTo(v.x, v.y)
    @_graphics.lineTo(v0.x, v0.y)

  DrawSegment: (p1, p2, color) ->
    @_graphics.lineStyle(@_line_width, color.color)
    @_graphics.alpha = @_alpha
    p1 = @_worldToScreen(p1)
    p2 = @_worldToScreen(p2)
    @_graphics.moveTo(p1.x, p1.y)
    @_graphics.lineTo(p2.x, p2.y)

  DrawSolidCircle: (center, radius, axis, color) ->
    @_graphics.beginFill(color.color)
    @_graphics.fillAlpha = @_fill_alpha
    @DrawCircle(center, radius, color)
    @_graphics.endFill()

    axis = axis.Copy()
    axis.Normalize()
    axis.Multiply(radius)
    edge = center.Copy()
    edge.Add(axis)
    @DrawSegment(center, edge, color)

  DrawSolidPolygon: (vertices, vertexCount, color) ->
    @_graphics.beginFill(color.color)
    @_graphics.fillAlpha = @_fill_alpha
    @DrawPolygon(vertices, vertexCount, color)
    @_graphics.endFill()

  DrawTransform: (xf) ->
    @_graphics.lineStyle(@_line_width, 0xFF0000)
    @_graphics.alpha = @_alpha

    p1 = @_worldToScreen(xf.position)
    p2 =
      x: xf.position.x + xf.R.col1.x
      y: xf.position.y + xf.R.col1.y
    p2 = @_worldToScreen(p2)
    p3 =
      x: xf.position.x + xf.R.col2.x
      y: xf.position.y + xf.R.col2.y
    p3 = @_worldToScreen(p3)

    @_graphics.moveTo(p1.x, p1.y)
    @_graphics.lineTo(p2.x, p2.y)

    @_graphics.moveTo(p1.x, p1.y)
    @_graphics.lineTo(p3.x, p3.y)

  GetAlpha: () ->
    return @_alpha

  GetDrawScale: () ->
    return @_scale

  GetFillAlpha: () ->
    return @_fill_alpha

  GetLineThickness: () ->
    return @_line_width

  SetAlpha: (@_alpha) ->

  SetDrawScale: (@_scale) ->

  SetLineThickness: (@_line_width) ->

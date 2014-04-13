
settings = {
  DEBUG: true
  DEBUG_DRAW: false
  PRINT_INPUT: false
  WIDTH: 1000
  HEIGHT: 500

  PADDLE_X: 20  # pixels from the edge

  PPM: 30  # pixels per meter
  BOX2D_TIME_STEP: 1 / 60
  BOX2D_VI: 10  # Velocity iterations
  BOX2D_PI: 10  # Position iterations

  BINDINGS:
    P1_UP:    87
    P1_DOWN:  83
    P1_LEFT:  65
    P1_RIGHT: 68
    P2_UP:    38
    P2_DOWN:  40
    P2_LEFT:  37
    P2_RIGHT: 39
    START:    32
}

b2Common = Box2D.Common
b2Math = Box2D.Common.Math
b2Vec2 = b2Math.b2Vec2
b2Collision = Box2D.Collision
b2Shapes = Box2D.Collision.Shapes
b2Dynamics = Box2D.Dynamics
b2Contacts = Box2D.Dynamics.Contacts
b2Controllers = Box2D.Dynamics.Controllers
b2Joints = Box2D.Dynamics.Joints
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

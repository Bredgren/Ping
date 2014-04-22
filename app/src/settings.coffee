
settings = {
  DEBUG: true
  DEBUG_DRAW: false
  PRINT_INPUT: false
  WIDTH: 1000
  HEIGHT: 500
  AUDIO_PATH: "assets/snd/"
  SOUNDS:
    PADDLE_CONTACT:
      ID: "Paddle contact"
      SRC: "paddle_contact.ogg"
    SCORE:
      ID: "Score"
      SRC: "score.ogg"
    START_TIMER:
      ID: "Start timer"
      SRC: "start_timer.ogg"
    START_BUZZER:
      ID: "Start buzzer"
      SRC: "start_buzzer.ogg"
    END_TIMER:
      ID: "End timer"
      SRC: "end_timer.ogg"
    END_BUZZER:
      ID: "End buzzer"
      SRC: "end_buzzer.ogg"

  PADDLE:
    X: 20  # pixels from the edge
    LENGTH: 75
    WIDTH: 10
    MOVE_FORCE: 80
    MAX_VEL: 60
    ANGLE: 20
    DAMPING_MOVE: 0
    DAMPING_STILL: 10

  BALL:
    SIZE: 15
    MIN_X_VEL: 20
    MAX_ANGLE: 60
    MAGNUS_FORCE: .05

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
    END:      27

  COLLISION_CATEGORY:
    PADDLE_L: 0x0001
    PADDLE_R: 0x0002
    BALL:     0x0004
    BOUNDARY: 0x0008
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

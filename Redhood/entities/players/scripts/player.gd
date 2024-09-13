class_name Player
extends CharacterBody2D

#region OnReady's
# Timers
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var jump_buffer_timer: Timer = $Timers/JumpBufferTimer
@onready var jump_release_timer: Timer = $Timers/JumpReleaseTimer

# Player
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var state_machine: Node = $StateMachine
@onready var wall_detection: RayCast2D = $WallDetection

# Physics
@onready var fall_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_DESCENT,2)) * -1.0
@onready var jump_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_PEAK,2)) * -1.0
@onready var jump_velocity: float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * -1.0
#endregion

#region Const
# Const
const MAX_JUMP_COUNT: int = 2
const DEFAULT_MODIFIER: float = 1.0
const JUMP_HEIGHT: float = 300.0
const JUMP_TIME_TO_PEAK: float = 0.5
const JUMP_TIME_TO_DESCENT: float = 0.415
const MOVE_SPEED: float = 500.0
const WALL_PUSH_POWER: float = 500.0
#endregion

#region Bools
# Bool Variables
var can_attach_to_walls: bool = true
var can_release_jump: bool = true
var allow_coyote_time: bool = true
var in_jump_buffer: bool = false
var is_currently_attached = false
var is_in_wall_stick_zone: bool = false
var is_wall_detected: bool = false
#endregion

#region Int and Floats
# Int Variables
var jump_count: int = 0

# Float Variables
var jump_modifier: float = DEFAULT_MODIFIER
var speed_modifier: float = DEFAULT_MODIFIER
var friction_multiplier:float
var wall_downward_friction: float
#endregion

#region Other Variables
# Vector2 Variables
var wall_normal: Vector2
var last_wall_norm: Vector2
#endregion

#region Main Methods
func _ready() -> void:
	state_machine.init(self)
	
	#Timer connections
	coyote_timer.timeout.connect(_on_coyote_timeout)
	jump_buffer_timer.timeout.connect(_on_jump_buffer_timeout)
	jump_release_timer.timeout.connect(_on_jump_release_timeout)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	handle_wall_detection()
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
#endregion

#region Control Methods
func move(direction) -> void:
	if !(state_machine.get_last_state().name == "WallLand" and state_machine.get_current_state().name == "Fall"):
		if (last_wall_norm == Vector2.RIGHT and direction < 0.0) or (last_wall_norm == Vector2.LEFT and direction > 0.0):
			speed_modifier = 0.35
		else:
			speed_modifier = DEFAULT_MODIFIER
	
	if direction:
		velocity.x = direction * (MOVE_SPEED * speed_modifier)
		flip_player()
	else:
		velocity.x = move_toward(velocity.x, 0, (MOVE_SPEED * speed_modifier))
	move_and_slide()


func flip_player() -> void:
	sprite.scale.x = sign(velocity.x) * abs(sprite.scale.x)
	collision.position.x = -6.5 if sprite.scale.x < 0 else 0.5
	wall_detection.target_position.x = sign(velocity.x) * abs(wall_detection.target_position.x)


func handle_wall_detection() -> void:
	wall_normal = get_wall_normal()
	is_wall_detected = wall_normal && wall_detection.is_colliding()


func apply_jump_force() -> void:
	velocity.y = jump_velocity * jump_modifier 


func apply_wall_jump() -> void:
	velocity.x = WALL_PUSH_POWER * sign(last_wall_norm.x)
	flip_player()
	apply_jump_force()


func check_wall_land() -> bool:
	if is_in_wall_stick_zone and is_wall_detected and can_release_jump and can_attach_to_walls:
		if (wall_normal == Vector2.RIGHT and Input.is_action_pressed("move_left")) or (wall_normal == Vector2.LEFT and Input.is_action_pressed("move_right")):
			return true
	return false
#endregion

#region Timer Timeouts
func _on_coyote_timeout() -> void:
	allow_coyote_time = false


func _on_jump_buffer_timeout() -> void:
	in_jump_buffer = false


func _on_jump_release_timeout() -> void:
	can_release_jump = true
#endregion


#region External Influnces
func set_wall_stick(wall_stick: bool, wall_friction: float = 1.0):
	is_in_wall_stick_zone = wall_stick
	wall_downward_friction = wall_friction
#endregion

class_name Player
extends CharacterBody2D

@onready var crouch = $SoundEvents/Crouch
@onready var ledge_grab = $SoundEvents/LedgeGrab
@onready var land = $SoundEvents/Land
@onready var wall_jump = $SoundEvents/WallJump
@onready var wall_land = $SoundEvents/WallLand
@onready var fall_sound = $SoundEvents/Fall
@onready var jump_sound = $SoundEvents/Jump
@onready var Run_sound = $SoundEvents/Run

@export var MAX_SPEED: float = 700.0
@export var acceleration: float = 50.0
@export_range(0.0,1.0) var friction:float = 0.35

#region OnReady's
# Timers
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var jump_buffer_timer: Timer = $Timers/JumpBufferTimer
@onready var jump_release_timer: Timer = $Timers/JumpReleaseTimer
@onready var detach_timer: Timer = $Timers/DetachTimer

# Player
@onready var top_collision: CollisionShape2D = $TopCollisionShape
@onready var bottom_collision: CollisionShape2D = $BottomCollisionShape
@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var state_machine: Node = $StateMachine
@onready var wall_detection: RayCast2D = $WallDetection
@onready var ledge_detection: RayCast2D = $LedgeDetection

# Physics
@onready var fall_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_DESCENT,2)) * -1.0
@onready var jump_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_PEAK,2)) * -1.0
@onready var jump_velocity: float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * -1.0
@onready var slide_velocity: float = ((2.0 * SLIDE_DISTANCE) / TIME_TO_SLIDE) * -1.0

#endregion

#region Const
# Const
const MAX_JUMP_COUNT: int = 2
const DEFAULT_MODIFIER: float = 1.0
const JUMP_HEIGHT: float = 300.0
const SLIDE_DISTANCE: float = 300.0
const JUMP_TIME_TO_PEAK: float = 0.5
const JUMP_TIME_TO_DESCENT: float = 0.5
const TIME_TO_SLIDE: float = 0.5
const HANG_TIME: float = 0.015
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
var is_wall_friction_set: bool = false
var external_forces_applied: bool = false
#endregion

#region Int and Floats
# Int Variables
var jump_count: int = 0
@export_range(1,MAX_JUMP_COUNT) var current_max_jumps: int:
	set(value):
		if value < MAX_JUMP_COUNT:
			current_max_jumps = value
		else:
			current_max_jumps = MAX_JUMP_COUNT

# Float Variables
var jump_modifier: float = DEFAULT_MODIFIER
var speed_modifier: float = DEFAULT_MODIFIER
#endregion

#region Other Variables
# Vector2 Variables
var wall_normal: Vector2
var last_wall_norm: Vector2
var external_forces: Vector2 = Vector2.ZERO
var wall_friction: Vector2 = Vector2.ZERO
var motion: Vector2 = Vector2.ZERO
var temp_external: Vector2
#endregion

#region Main Methods
func _ready() -> void:
	state_machine.init(self)
	
	#Timer connections
	coyote_timer.timeout.connect(_on_coyote_timeout)
	jump_buffer_timer.timeout.connect(_on_jump_buffer_timeout)
	jump_release_timer.timeout.connect(_on_jump_release_timeout)
	detach_timer.timeout.connect(_on_detach_timeout)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	handle_wall_detection()
	state_machine.process_physics(delta)
	apply_external_forces()
	move_and_slide()


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
#endregion

#region Control Methods
func move(direction) -> void:
	if direction:
		if sign(direction) != sign(motion.x) and motion.x != 0 and is_on_floor():
				motion.x = lerp(motion.x, direction, friction)
		else:
				motion.x = clamp(motion.x + (acceleration * sign(direction)), -MAX_SPEED * speed_modifier, MAX_SPEED * speed_modifier)
		flip_player(direction)
	elif !state_machine.get_last_state.name == "WallJump" and !state_machine.get_current_state.name == "WallJump":
		motion.x = lerp(motion.x, 0.0, friction)


func flip_player(direction) -> void:
	sprite.scale.x = sign(direction) * abs(sprite.scale.x)
	top_collision.position.x = -6.5 if sprite.scale.x < 0 else 0.5
	bottom_collision.position.x = -6.5 if sprite.scale.x < 0 else 0.5
	wall_detection.target_position.x = sign(direction) * abs(wall_detection.target_position.x)
	ledge_detection.target_position.x = sign(direction) * abs(ledge_detection.target_position.x)


func handle_wall_detection() -> void:
	wall_normal = get_wall_normal()
	is_wall_detected = wall_normal && wall_detection.is_colliding()


func apply_external_forces():
	if velocity.x <= MAX_SPEED or external_forces_applied or state_machine.get_current_state.name != "Run" :
		velocity = motion + external_forces.lerp(external_forces, friction)
	else:
		velocity.x = lerp(velocity.x,MAX_SPEED, 0.05)


func apply_jump_force() -> void:
	motion.y = jump_velocity * jump_modifier 
	jump_modifier = DEFAULT_MODIFIER


func apply_wall_jump() -> void:
	motion.x = WALL_PUSH_POWER * sign(last_wall_norm.x)
	flip_player(sign(last_wall_norm.x))
	apply_jump_force()


func check_wall_land() -> bool:
	if is_in_wall_stick_zone and is_wall_detected and can_attach_to_walls:
		if (wall_normal == Vector2.RIGHT and Input.is_action_pressed("move_left")) or (wall_normal == Vector2.LEFT and Input.is_action_pressed("move_right")):
			if !is_wall_friction_set:
				set_external_forces(wall_friction)
				is_wall_friction_set = true
			return true
	
	if is_wall_friction_set:
		set_external_forces(-wall_friction)
		is_wall_friction_set = false
	return false
#endregion

#region Timer Timeouts
func _on_coyote_timeout() -> void:
	allow_coyote_time = false


func _on_jump_buffer_timeout() -> void:
	in_jump_buffer = false


func _on_jump_release_timeout() -> void:
	can_release_jump = true

func _on_detach_timeout() -> void:
	can_attach_to_walls = true
#endregion


#region External Influnces
func set_wall_stick(wall_stick: bool, force: Vector2):
	is_in_wall_stick_zone = wall_stick
	wall_friction = force


func set_external_forces(forces:Vector2) -> void:
	external_forces += forces
	external_forces_applied = abs(external_forces) > Vector2.ZERO
#endregion

class_name Player
extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var state_machine: Node = $StateMachine
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var jump_velocity: float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * -1.0
@onready var jump_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_PEAK,2)) * -1.0
@onready var fall_gravity: float = ((-2.0 * JUMP_HEIGHT) / pow(JUMP_TIME_TO_DESCENT,2)) * -1.0

# Use to reset modifiers to 1.0
const DEFAULT_MODIFIER: float = 1.0

# Jump Const
const JUMP_HEIGHT: float = 500.0
const JUMP_TIME_TO_PEAK: float = 0.75
const JUMP_TIME_TO_DESCENT: float = 0.415
const JUMP_BUFFER_TIME: float =0.2
const COYOTE_TIME: float = 0.2
const WALL_PUSH_POWER: float = 500.0
const MAX_JUMP_COUNT: int = 2

# Movement Const
const MOVE_SPEED: float = 500.0

# Controls Const
const DOUBLE_TAP_TIME: float = 0.2

# Jump Variables
var in_coyote_time: bool = true
var in_jump_buffer: bool = false
var can_stick_on_wall: bool = true
var jump_count: int = 0
var jump_modifier: float = DEFAULT_MODIFIER

# Movement Variables
var speed_modifier: float = DEFAULT_MODIFIER
var friction_multiplier:float:
	set(value):
		friction_multiplier = value

# Controls Var
var is_wall_detected: bool = false
var wall_normal: Vector2
var last_wall_norm: Vector2

# Timers
var double_tap_timer:Timer = Timer.new()
var jump_buffer_timer:Timer = Timer.new()
var coyote_timer:Timer = Timer.new()


func _ready() -> void:
	create_coyote_timer()
	create_jump_buffer_timer()
	state_machine.init(self)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	wall_normal = get_wall_normal()
	if wall_normal:
		is_wall_detected = true
	else:
		is_wall_detected = false
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


#Move character
func move(direction) -> void:
	if direction:
		velocity.x = direction * (MOVE_SPEED * speed_modifier)
		sprite.scale.x = sign(velocity.x) * abs(sprite.scale.x)
		if sprite.scale.x < 0:
			collision.position.x = -6.5
		else:
			collision.position.x = 0.5
	else:
		velocity.x = move_toward(velocity.x, 0, (MOVE_SPEED * speed_modifier))
	move_and_slide()


#Makes character jump
func apply_jump_force() -> void:
	velocity.y = jump_velocity * jump_modifier 


func apply_wall_jump() -> void:
	if last_wall_norm == Vector2.RIGHT:
		velocity.x = WALL_PUSH_POWER
	elif  last_wall_norm == Vector2.LEFT:
		velocity.x = -WALL_PUSH_POWER
	sprite.scale.x = sign(velocity.x) * abs(sprite.scale.x)
	if sprite.scale.x < 0:
		collision.position.x = -6.5
	else:
		collision.position.x = 0.5
	velocity.y = jump_velocity * jump_modifier

#Coyote State Controls
func create_coyote_timer() -> void:
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.autostart = false
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.timeout.connect(_coyote_timedout)


func start_coyote_time() -> void:
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.start()	


func stop_coyote_time() -> void:
	coyote_timer.stop()


func _coyote_timedout() -> void:
	in_coyote_time = false


# Jump Buffer Controls
func create_jump_buffer_timer() -> void:
	add_child(jump_buffer_timer)
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.autostart = false
	jump_buffer_timer.wait_time = JUMP_BUFFER_TIME
	jump_buffer_timer.timeout.connect(jump_buffer_timedout)


func start_jump_buffer_time() -> void:
	jump_buffer_timer.start()
	in_jump_buffer = true


func stop_jump_buffer_time() -> void:
	jump_buffer_timer.stop()


func jump_buffer_timedout() -> void:
	in_jump_buffer = false


# Double Tap Timer
func create_double_tap_timer() -> void:
	add_child(jump_buffer_timer)
	double_tap_timer.one_shot = true
	double_tap_timer.autostart = false
	double_tap_timer.wait_time = DOUBLE_TAP_TIME
	double_tap_timer.timeout.connect(double_tap_timedout)


func start_double_tap_timer() -> void:
	double_tap_timer.start()


func stop_double_tap_timer() -> void:
	double_tap_timer.stop()


func double_tap_timedout() -> void:
	pass

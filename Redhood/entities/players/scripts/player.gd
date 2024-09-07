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
var can_attach_to_walls: bool = true
var is_currently_attached = false
var can_release_jump: bool = true
var wall_time = 0.0
var jump_count: int = 0
var jump_modifier: float = DEFAULT_MODIFIER
var jump_release_time: float = 0.0

# Movement Variables
var speed_modifier: float = DEFAULT_MODIFIER
var friction_multiplier:float

# Controls Var
var is_wall_detected: bool = false
var is_in_wall_stick_zone: bool = false
var wall_downward_friction: float
var wall_normal: Vector2
var last_wall_norm: Vector2

# Timers
var double_tap_timer: Timer = Timer.new()
var jump_buffer_timer: Timer = Timer.new()
var coyote_timer: Timer = Timer.new()
var wall_timer: Timer = Timer.new()
var jump_release_timer: Timer = Timer.new()

func _ready() -> void:
	create_coyote_timer()
	create_jump_buffer_timer()
	create_wall_timer()
	create_jump_release_timer()
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


# Wall Timer
func create_wall_timer() -> void:
	add_child(wall_timer)
	wall_timer.one_shot = true
	wall_timer.autostart = false
	wall_timer.timeout.connect(wall_timedout)


func start_wall_timer() -> void:
	wall_timer.wait_time = wall_time
	wall_timer.start()


func stop_wall_timer() -> void:
	wall_timer.stop()


func wall_timedout() -> void:
	is_currently_attached = false

# Jump Release Timer
func create_jump_release_timer() -> void:
	add_child(jump_release_timer)
	jump_release_timer.one_shot = true
	jump_release_timer.autostart = false
	jump_release_timer.timeout.connect(jump_release_timedout)


func start_jump_release_timer() -> void:
	jump_release_timer.wait_time = jump_release_time
	jump_release_timer.start()


func stop_jump_release_timer() -> void:
	jump_release_timer.stop()


func jump_release_timedout() -> void:
	can_release_jump = true

func set_wall_stick(wall_stick: bool, wall_friction: float = 0.5):
	is_in_wall_stick_zone = wall_stick
	wall_downward_friction = wall_friction

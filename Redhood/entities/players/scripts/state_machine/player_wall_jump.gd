extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var wall_landing_state: State


var _direction:float = 0.0
var _jump_release_time: float
var _wall_stick_min_time: float
var _can_control: bool
var _initial_run: bool
var _can_stick_to_walls: bool


func enter() -> void:
	animation_name = "jump"
	parent.jump_modifier = 0.8
	parent.apply_wall_jump()
	parent.jump_count += 1
	parent.in_coyote_time = false
	parent.in_jump_buffer = false
	_jump_release_time = parent.JUMP_TIME_TO_PEAK * parent.jump_modifier
	_wall_stick_min_time = 0.1
	_can_control = false
	_can_stick_to_walls = false
	_initial_run = true 
	get_tree().create_timer(_jump_release_time).timeout.connect(_jump_release_timedout)
	get_tree().create_timer(_wall_stick_min_time).timeout.connect(_wall_stick_min_timedout)
	super()


func process_physics(delta: float) -> State:
	parent.velocity.y += parent.jump_gravity * delta
	if parent.is_in_wall_stick_zone:
		if parent.is_on_wall_only() && _can_stick_to_walls:
			if parent.wall_normal == Vector2.RIGHT && Input.is_action_pressed("move_left"):
				return wall_landing_state
			elif parent.wall_normal == Vector2.LEFT && Input.is_action_pressed("move_right"):
				return wall_landing_state
	
	if Input.is_action_just_pressed("jump") and parent.jump_count >= parent.MAX_JUMP_COUNT and !_initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.start_jump_buffer_time()
	
	if parent.velocity.y > 0.1:
		return fall_state
	
	if _can_control:
		_direction = Input.get_axis("move_left", "move_right")
		parent.move(_direction)
	else:
		parent.move_and_slide()
	
	_initial_run = false
	if parent.is_on_floor():
		parent.in_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			enter()
		if _direction != 0:
			return run_state
		return idle_state
	
	return null


func _wall_stick_min_timedout() -> void:
	_can_stick_to_walls = true


func _jump_release_timedout() -> void:
	_can_control = true

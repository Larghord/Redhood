extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var wall_landing_state: State


var _direction:float = 0.0
var _initial_run: bool


func enter() -> void:
	animation_name = "jump"
	parent.jump_modifier = 0.8
	parent.apply_wall_jump()
	parent.allow_coyote_time  = false
	parent.in_jump_buffer = false
	parent.jump_release_timer.wait_time = (parent.JUMP_TIME_TO_PEAK * parent.jump_modifier) * 0.6
	parent.can_release_jump = false
	_initial_run = true 
	parent.jump_release_timer.start()
	super()


func process_physics(delta: float) -> State:
	parent.velocity.y += parent.jump_gravity * delta
	if parent.check_wall_land():
			return wall_landing_state
	
	if Input.is_action_just_pressed("jump") and parent.jump_count >= parent.MAX_JUMP_COUNT and !_initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.jump_buffer_timer.start()
	
	if parent.velocity.y > 0.1:
		return fall_state
	
	if parent.can_release_jump:
		_direction = Input.get_axis("move_left", "move_right")
		parent.move(_direction)
	else:
		parent.move_and_slide()
	
	_initial_run = false
	if parent.is_on_floor():
		parent.allow_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			enter()
		if _direction != 0:
			return run_state
		return idle_state
	
	return null

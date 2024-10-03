extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var wall_landing_state: State
@export var wall_jump_state: State 
@export var ledge_grab_state: State

var _initial_run: bool = false


func enter() -> void:
	parent.apply_jump_force()
	animation_name = "jump"
	parent.allow_coyote_time = false
	parent.in_jump_buffer = false
	parent.coyote_timer.stop()
	parent.can_release_jump = false
	parent.jump_count += 1
	parent.jump_release_timer.wait_time = (parent.JUMP_TIME_TO_PEAK * parent.jump_modifier) * 0.4
	parent.jump_modifier = parent.jump_modifier / (parent.jump_count)
	parent.jump_release_timer.start()
	parent.last_wall_norm = Vector2.ZERO
	_initial_run = true
	parent.jump_sound.post_event()
	super()


func process_physics(delta: float) -> State:
	parent.motion.y += parent.jump_gravity * delta
	
	if parent.check_wall_land():
		if parent.in_jump_buffer:
			return wall_jump_state
		return wall_landing_state
	
	if (!Input.is_action_pressed("jump") and parent.can_release_jump) or parent.is_on_ceiling():
		parent.motion.y =  0
		return fall_state
	
	if Input.is_action_just_pressed("jump") and parent.jump_count <= parent.current_max_jumps and !_initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.jump_buffer_timer.start()
		elif parent.jump_count <= parent.current_max_jumps:
			return jump_state
	
	if parent.motion.y > 0:
		return fall_state
	
	var direction:float = Input.get_axis("move_left", "move_right")
	parent.move(direction)
	
	if parent.is_on_floor() and !_initial_run:
		parent.land.post_event()
		parent.jump_modifier = parent.DEFAULT_MODIFIER
		parent.jump_count = 0
		if parent.in_jump_buffer:
			return jump_state
		if direction != 0:
			return run_state
		return idle_state
	_initial_run = false
	
	
	return null


func exit() -> void:
	parent.jump_release_timer.stop()

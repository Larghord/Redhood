extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var wall_landing_state: State

const JUMP_RELEASE_WAIT: float = parent.JUMP_TIME_TO_PEAK * 0.4

var can_release_jump: bool = true
var initial_run: bool = false
var was_last_wall_left: bool

var direction:float

func enter() -> void:
	animation_name = "jump"
	if parent.wall_check_left.is_colliding():
		was_last_wall_left = true
	elif  parent.wall_check_right.is_colliding():
		was_last_wall_left = false
	parent.apply_wall_jump_force(was_last_wall_left)
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.in_coyote_time = false
	parent.in_jump_buffer = false
	parent.jump_count = 0
	parent.stop_coyote_time()
	can_release_jump = false
	
	initial_run = true
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += parent.jump_gravity * delta
	if parent.is_on_wall_only():
		if !was_last_wall_left && parent.wall_check_left.is_colliding() && Input.is_action_pressed("move_left"):
			return wall_landing_state
		elif was_last_wall_left && parent.wall_check_right.is_colliding() && Input.is_action_pressed("move_right"):
			return wall_landing_state
		
	parent.velocity.y += parent.jump_gravity * delta
	
	if Input.is_action_just_pressed("jump") && parent.jump_count >= parent.MAX_JUMP_COUNT && !initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.start_jump_buffer_time()
		elif parent.jump_count < parent.MAX_JUMP_COUNT:
			enter()
	
	if parent.velocity.y > 0 && !initial_run:
		return fall_state
	
	initial_run = false
	if parent.is_on_floor():
		parent.in_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			return jump_state
		if direction != 0:
			return run_state
		return idle_state
	
	return null

func jump_release_timedout() -> void:
	can_release_jump = true

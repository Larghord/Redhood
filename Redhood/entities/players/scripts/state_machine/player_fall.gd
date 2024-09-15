extends State

@export var idle_state: State
@export var run_state: State
@export var crouch_state:State
@export var jump_state:State
@export var wall_landing_state: State
@export var ledge_grab_state: State

func enter() -> void:
	animation_name = "fall"
	parent.allow_coyote_time = false
	parent.coyote_timer.stop()
	super()


func process_physics(delta: float) -> State:
	parent.motion.y += parent.fall_gravity * delta
	
	if parent.ledge_detection.is_colliding() and not parent.wall_detection.is_colliding() and not parent.is_on_floor() and parent.state_machine.get_last_state().name != "Run" and parent.state_machine.get_last_state().name != "LedgeGrab" and !Input.is_action_pressed("crouch"):
		return ledge_grab_state
	
	if parent.check_wall_land():
		return wall_landing_state
	
	if Input.is_action_just_pressed("jump"):
		if parent.jump_buffer_timer.is_stopped() and parent.jump_count >= parent.current_max_jumps:
			parent.jump_buffer_timer.start()
		elif parent.jump_count < parent.current_max_jumps:
			return jump_state
	
	var direction := Input.get_axis("move_left", "move_right")
	parent.move(direction)
	
	if parent.is_on_floor():
		parent.can_attach_to_walls = true
		parent.last_wall_norm = Vector2.ZERO
		parent.jump_count = 0
		if sign(direction) != sign(parent.motion.x):
			parent.motion.x = 0
		if parent.in_jump_buffer:
			return jump_state
		if direction != 0:
			return run_state
		if Input.is_action_pressed("crouch"):
			return crouch_state
		return idle_state
	return null

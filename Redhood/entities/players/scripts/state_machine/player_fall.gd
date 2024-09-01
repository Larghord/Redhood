extends State

@export var idle_state: State
@export var run_state: State
@export var crouch_state:State
@export var jump_state:State

func enter() -> void:
	animation_name = "fall"
	parent.in_coyote_time = false
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.stop_coyote_time()
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += parent.fall_gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		if parent.jump_buffer_timer.is_stopped() and parent.jump_count >= parent.MAX_JUMP_COUNT:
			parent.start_jump_buffer_time()
		elif parent.jump_count < parent.MAX_JUMP_COUNT:
			return jump_state
	
	var direction := Input.get_axis("move_left", "move_right")
	
	parent.move(direction)
	
	if parent.is_on_floor():
		parent.in_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			return jump_state
		if direction != 0:
			return run_state
		if Input.is_action_pressed("crouch"):
			return crouch_state
		return idle_state
	return null

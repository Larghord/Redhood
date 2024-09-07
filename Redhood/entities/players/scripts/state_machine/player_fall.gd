extends State

@export var idle_state: State
@export var run_state: State
@export var crouch_state:State
@export var jump_state:State
@export var wall_landing_state: State

func enter() -> void:
	animation_name = "fall"
	parent.in_coyote_time = false
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.stop_coyote_time()
	super()


func process_physics(delta: float) -> State:
	parent.velocity.y += parent.fall_gravity * delta
	if parent.is_in_wall_stick_zone:
		if parent.is_on_wall_only() && parent.can_release_jump && parent.can_attach_to_walls:
			if parent.wall_normal == Vector2.RIGHT && Input.is_action_pressed("move_left"):
				return wall_landing_state
			elif parent.wall_normal == Vector2.LEFT && Input.is_action_pressed("move_right"):
				return wall_landing_state
	
	if Input.is_action_just_pressed("jump"):
		if parent.jump_buffer_timer.is_stopped() and parent.jump_count >= parent.MAX_JUMP_COUNT:
			parent.start_jump_buffer_time()
		elif parent.jump_count < parent.MAX_JUMP_COUNT:
			return jump_state
	
	var direction := Input.get_axis("move_left", "move_right")
	parent.move(direction)
	
	if parent.is_on_floor():
		parent.can_attach_to_walls = true
		parent.last_wall_norm = Vector2.ZERO
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

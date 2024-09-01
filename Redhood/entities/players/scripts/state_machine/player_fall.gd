extends State

@export var idle_state: State
@export var run_state: State
@export var crouch_state:State

func enter() -> void:
	animation_name = "fall"
	parent.in_coyote_time = false
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.stop_coyote_time()
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	
	parent.move(direction)
	
	if parent.is_on_floor():
		parent.in_coyote_time = true
		if direction != 0:
			return run_state
		if Input.is_action_pressed("crouch"):
			return crouch_state
		return idle_state
	return null

extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State

func enter() -> void:
	animation_name = "jump"
	parent.in_coyote_time = false
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.stop_coyote_time()
	super()

func process_input(_event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	if Input.is_action_just_released("jump"):
		parent.velocity.y =  0
		return fall_state
		
	parent.velocity.y += gravity * delta
	
	if parent.velocity.y > 0:
		return fall_state
	
	var direction:float = Input.get_axis("move_left", "move_right")
	
	parent.move(direction)
	
	if parent.is_on_floor():
		parent.in_coyote_time = true
		if direction != 0:
			return run_state
		return idle_state
	
	return null

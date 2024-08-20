extends State

@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	animation_name = "fall"
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	
	parent.move(direction)
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	return null

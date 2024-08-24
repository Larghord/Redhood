extends State

@export var fall_state: State
@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	animation_name = "jump"
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	
	if parent.velocity.y > 0:
		return fall_state
	
	var direction:float = parent.get_direction()
	
	parent.move(direction)
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	
	return null

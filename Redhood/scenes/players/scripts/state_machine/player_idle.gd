extends State

@export var fall_state: State
@export var jump_state: State
@export var walk_state: State

func enter() -> void:
	animation_name = "idle"
	super()
	parent.velocity.x = 0

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		parent.apply_jump_foce()
		return jump_state
	if Input.get_axis("move_left","move_right"):
		return walk_state
	return null

func process_physics(_delta: float) -> State:	
	if !parent.is_on_floor():
		return fall_state
	return null

extends State

@export var fall_state: State
@export var idle_state: State
@export var jump_state: State
@export var run_state: State
func enter() -> void:
	animation_name = "walk"
	super()

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		parent.apply_jump_foce()
		return jump_state
	if Input.is_action_just_pressed("run"):
		return run_state
	return null

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	
	var direction := Input.get_axis("move_left","move_right")
		
	
	if direction == 0:
		return idle_state
	
	parent.move(direction)
	
	if !parent.is_on_floor():
		return fall_state
	return null

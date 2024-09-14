extends State

@export var fall_state: State
@export var jump_state: State
@export var run_state: State
@export var crouch_state: State


func enter() -> void:
	animation_name = "idle"
	parent.velocity.x = 0
	if parent.is_on_floor():
		parent.allow_coyote_time = true
	super()


func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump'):
		return jump_state
	if Input.get_axis("move_left","move_right"):
		return run_state
	return null


func process_physics(_delta: float) -> State:
	if Input.is_action_pressed("crouch"):
		return crouch_state
	if !parent.is_on_floor():
			return fall_state
	return null

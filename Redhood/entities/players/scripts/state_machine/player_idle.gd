extends State

@export var fall_state: State
@export var jump_state: State
@export var run_state: State
@export var crouch_state: State


func enter() -> void:
	animation_name = "idle"
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.velocity.x = 0
	parent.in_coyote_time = true
	super()


func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump') and parent.in_coyote_time:
		return jump_state
	if Input.get_axis("move_left","move_right"):
		return run_state
	if Input.is_action_pressed("crouch"):
		return crouch_state
	return null


func process_physics(_delta: float) -> State:
	if !parent.is_on_floor():
		if !parent.in_coyote_time:
			return fall_state
		elif parent.coyote_timer.is_stopped():
			parent.start_coyote_time()
	if parent.is_on_floor():
		if !parent.coyote_timer.is_stopped():
			parent.stop_coyote_time()
	return null

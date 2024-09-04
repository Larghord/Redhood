extends State

@export var idle_state: State
@export var fall_state: State
@export var jump_state: State
@export var run_state: State


func enter() -> void:
	animation_name = "crouch idle"
	parent.velocity.x = 0
	parent.in_coyote_time = true
	parent.jump_modifier = 2.0
	super()


func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump') and parent.in_coyote_time:
		parent.apply_jump_foce()
		return jump_state
	if Input.get_axis("move_left","move_right"):
		return run_state
	if Input.is_action_just_released("crouch"):
		return idle_state
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

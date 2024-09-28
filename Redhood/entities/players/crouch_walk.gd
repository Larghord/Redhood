extends State

@export var fall_state: State
@export var crouch_state: State
@export var idle_state: State
@export var jump_state: State
@export var run_state: State

func enter() -> void:
	parent.speed_modifier = 0.3
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.motion.y = 0
	if parent.is_on_floor():
		parent.allow_coyote_time = true
	animation_name = "crouch walk"
	super()

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_released("crouch") and Input.get_axis("move_left","move_right"):
		return run_state
	if Input.is_action_just_released("crouch"):
		return idle_state
	return null

func process_physics(_delta: float) -> State:
	if Input.is_action_just_pressed('jump') and parent.allow_coyote_time:
		return jump_state
	
	var direction := Input.get_axis("move_left","move_right")
	
	if direction == 0:
		return crouch_state
	
	parent.move(direction)
	
	if !parent.is_on_floor():
		if !parent.allow_coyote_time:
			return fall_state
		elif parent.coyote_timer.is_stopped():
			parent.coyote_timer.start()
	if parent.is_on_floor():
		if !parent.coyote_timer.is_stopped():
			parent.coyote_timer.stop()
	return null

func exit() -> void:
	parent.speed_modifier = parent.speed_modifier
	if !parent.coyote_timer.is_stopped():
			parent.coyote_timer.stop()

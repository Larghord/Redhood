extends State

@export var fall_state: State
@export var idle_state: State
@export var jump_state: State
@export var slide_state: State


func enter() -> void:
	parent.speed_modifier = parent.DEFAULT_MODIFIER
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.motion.y = 0
	if parent.is_on_floor():
		parent.allow_coyote_time = true
	animation_name = "run"
	super()

func process_input(_event: InputEvent) -> State:
	if Input.is_action_pressed("crouch"):
			return slide_state
	return null

func process_physics(_delta: float) -> State:
	if Input.is_action_just_pressed('jump') and parent.allow_coyote_time:
		return jump_state
	
	var direction := Input.get_axis("move_left","move_right")
	
	if direction == 0:
		return idle_state
	
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
	if !parent.coyote_timer.is_stopped():
			parent.coyote_timer.stop()

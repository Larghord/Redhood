extends State

@export var crouch_state: State
@export var run_state: State
@export var idle_state: State
@export var fall_state: State
@export var jump_state: State


func enter() -> void:
	animation_name = "slide"
	parent.motion.x = parent.velocity.x * 1.4
	parent.slide_start.post_event()
	super()

func process_physics(_delta: float) -> State:
	if !parent.is_on_floor():
		return fall_state
	parent.motion.x = lerp(parent.motion.x, 0.0, 0.015)
	parent.velocity.x = parent.motion.x
	
	if abs(parent.motion.x) < 45.0:
		if Input.is_action_pressed("crouch"):
			return crouch_state
		return idle_state
	
	if parent.motion.x and not Input.is_action_pressed("crouch"):
		if Input.get_axis("move_left","move_right"):
			return run_state
	
	if Input.is_action_pressed("jump"):
		return jump_state
	return null
	

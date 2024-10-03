extends State

@export var jump_state: State
@export var fall_state: State

func enter() -> void:
	parent.last_wall_norm = parent.wall_normal
	animation_name = "wall land"
	parent.motion.y = 0
	parent.motion.x = 0
	parent.jump_count = 1
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.ledge_grab.post_event()
	super()

func process_input(_event: InputEvent) -> State:
	if Input.is_action_pressed("jump"):
		return jump_state
	return null

func process_physics(_delta: float) -> State:
	
	if Input.is_action_just_pressed("crouch") or (parent.last_wall_norm != Vector2.RIGHT and Input.is_action_just_pressed("move_left")):
		return fall_state
	if parent.last_wall_norm != Vector2.LEFT and Input.is_action_just_pressed("move_right"):
		return fall_state
	
	return null
func exit() -> void:
	parent.ledge_grab.stop_event()

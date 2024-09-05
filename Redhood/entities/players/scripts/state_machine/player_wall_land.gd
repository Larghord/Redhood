extends  State

@export var fall_state:State
@export var wall_jump_state:State

var _is_on_wall: bool


func enter() -> void:
	parent.last_wall_norm = parent.wall_normal
	parent.is_on_wall = true
	animation_name = "wall land"
	parent.jump_count = 0
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.wall_time = 1.0
	parent.start_wall_timer()
	super()


func process_physics(_delta: float) -> State:
	if parent.last_wall_norm != Vector2.RIGHT && Input.is_action_just_released("move_right"):
		parent.is_on_wall = false
	if parent.last_wall_norm != Vector2.LEFT && Input.is_action_just_released("move_left"):
		parent.is_on_wall = false
	if Input.is_action_just_pressed("jump"):
		return wall_jump_state
	if !parent.is_on_wall:
		parent.can_attach_to_walls = false
		return fall_state
	return null

func exit() -> void:
	parent.stop_wall_timer()

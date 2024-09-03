extends  State

@export var fall_state:State
@export var wall_jump_state:State

const WALL_STICK_TIME: float = 1

var is_on_wall: bool


func enter() -> void:
	is_on_wall = true
	animation_name = "wall land"
	parent.velocity = Vector2.ZERO
	get_tree().create_timer(WALL_STICK_TIME).timeout.connect(end_state)
	super()

func process_physics(_delta: float) -> State:
	if Input.is_action_just_pressed("jump"):
		return wall_jump_state
	if Input.is_action_pressed("crouch"):
		return fall_state
	if !is_on_wall:
		return fall_state
	return null

func end_state() -> void:
	is_on_wall = false

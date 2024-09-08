extends  State

@export var idle_state: State
@export var fall_state:State
@export var wall_jump_state:State


func enter() -> void:
	parent.last_wall_norm = parent.wall_normal
	parent.is_currently_attached = true
	animation_name = "wall land"
	parent.velocity.y = 0
	parent.jump_count = 0
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	#parent.wall_time = 1.0
	#parent.start_wall_timer()
	super()


func process_physics(_delta: float) -> State:
	parent.velocity.y += (gravity * parent.wall_downward_friction) * _delta
	parent.move_and_slide()
	if parent.last_wall_norm != Vector2.RIGHT && Input.is_action_just_released("move_right"):
		parent.is_currently_attached = false
	if parent.last_wall_norm != Vector2.LEFT && Input.is_action_just_released("move_left"):
		parent.is_currently_attached = false
	if Input.is_action_just_pressed("jump"):
		return wall_jump_state
	if !parent.is_currently_attached:
		parent.can_attach_to_walls = false
		return fall_state
	if parent.is_on_floor():
		return idle_state
	elif !parent.is_wall_detected && parent.velocity.y <0.0:
		parent.velocity.y = gravity * parent.wall_downward_friction * 2
		parent.move_and_slide()
		return fall_state
	elif !parent.is_wall_detected && parent.velocity.y >0.0:
		return fall_state
	return null

#func exit() -> void:
#	parent.stop_wall_timer()

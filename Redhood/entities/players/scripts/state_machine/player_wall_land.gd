extends  State

@export var idle_state: State
@export var fall_state:State
@export var wall_jump_state:State
@export var jump_state: State


func enter() -> void:
	parent.last_wall_norm = parent.wall_normal
	parent.is_currently_attached = true
	animation_name = "wall land"
	parent.motion.y = 0
	parent.motion.x = 0
	parent.jump_count = 1 
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.wall_land.post_event()
	super()


func process_physics(_delta: float) -> State:
	if parent.last_wall_norm != Vector2.RIGHT and Input.is_action_just_released("move_right"):
		parent.is_currently_attached = false
	
	if parent.last_wall_norm != Vector2.LEFT and Input.is_action_just_released("move_left"):
		parent.is_currently_attached = false
		
	if parent.external_forces_applied and parent.external_forces.y < 0.0:
		parent.jump_modifier = ( parent.external_forces.y / parent.jump_velocity) + 1.0 

		
	if !parent.wall_detection.is_colliding() and  parent.wall_normal == parent.last_wall_norm and parent.external_forces.y < 0.0:
		return jump_state
	
	if Input.is_action_just_pressed("jump"):
		return wall_jump_state
	
	if !parent.is_currently_attached:
		parent.can_attach_to_walls = false
		parent.detach_timer.start()
		return fall_state
	
	if parent.is_on_floor():
		return idle_state
	elif !parent.is_wall_detected and parent.velocity.y <0.1:
		return fall_state
	elif !parent.is_wall_detected and parent.velocity.y > 0.1:
		return fall_state
	return null
	
func exit() -> void:
	parent.wall_land.stop_event()

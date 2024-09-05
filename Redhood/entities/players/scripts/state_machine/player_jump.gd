extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State
@export var wall_landing_state: State


var _initial_run: bool = false


func enter() -> void:
	parent.apply_jump_force()
	animation_name = "jump"
	parent.in_coyote_time = false
	parent.in_jump_buffer = false
	parent.jump_modifier =(parent.jump_count + 1) / parent.DEFAULT_MODIFIER 
	parent.jump_release_time = (parent.JUMP_TIME_TO_PEAK * parent.jump_modifier) * 0.4
	parent.jump_count += 1
	parent.stop_coyote_time()
	parent.can_release_jump = false
	parent.start_jump_release_timer()
	_initial_run = true
	super()


func process_input(_event: InputEvent) -> State:
	return null


func process_physics(delta: float) -> State:
	parent.velocity.y += parent.jump_gravity * delta
	if parent.is_on_wall_only() && parent.can_release_jump && parent.can_attach_to_walls:
		if parent.wall_normal == Vector2.RIGHT && Input.is_action_pressed("move_left"):
			return wall_landing_state
		elif parent.wall_normal == Vector2.LEFT && Input.is_action_pressed("move_right"):
			return wall_landing_state
	
	if !Input.is_action_pressed("jump") and parent.can_release_jump:
		parent.velocity.y =  0
		return fall_state
	
	if Input.is_action_just_pressed("jump") and parent.jump_count >= parent.MAX_JUMP_COUNT and !_initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.start_jump_buffer_time()
		elif parent.jump_count < parent.MAX_JUMP_COUNT:
			enter()
	
	if parent.velocity.y > 0:
		return fall_state
	
	var direction:float = Input.get_axis("move_left", "move_right")
	parent.velocity.y += parent.jump_gravity * delta
	parent.move(direction)
	
	_initial_run = false
	if parent.is_on_floor():
		parent.in_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			enter()
		if direction != 0:
			return run_state
		return idle_state
	
	return null


func exit() -> void:
	parent.stop_jump_release_timer()

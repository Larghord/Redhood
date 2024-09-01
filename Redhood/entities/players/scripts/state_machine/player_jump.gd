extends State

@export var fall_state: State
@export var idle_state: State
@export var run_state: State

var initial_run = false

func enter() -> void:
	parent.apply_jump_foce()
	animation_name = "jump"
	parent.in_coyote_time = false
	parent.in_jump_buffer = false
	parent.jump_modifier = parent.DEFAULT_MODIFIER
	parent.jump_count += 1
	parent.stop_coyote_time()
	
	initial_run = true
	super()

func process_input(_event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	if Input.is_action_just_released("jump"):
		parent.velocity.y =  0
		return fall_state
		
	parent.velocity.y += parent.jump_gravity * delta
	
	if Input.is_action_just_pressed("jump") and parent.jump_count >= parent.MAX_JUMP_COUNT and !initial_run:
		if parent.jump_buffer_timer.is_stopped():
			parent.start_jump_buffer_time()
		elif parent.jump_count < parent.MAX_JUMP_COUNT:
			enter()
	
	if parent.velocity.y > 0:
		return fall_state
	
	var direction:float = Input.get_axis("move_left", "move_right")
	
	parent.move(direction)
	
	initial_run = false
	if parent.is_on_floor():
		parent.in_coyote_time = true
		parent.jump_count = 0
		if parent.in_jump_buffer:
			enter()
		if direction != 0:
			return run_state
		return idle_state
	
	return null

extends State

@export var fall_state: State
@export var idle_state: State
@export var jump_state: State
@export var run_state: State

func enter() -> void:
	parent.speed_modifier = parent.DEFAULT_MODIFIER
	parent.jump_modifier = 0.5
	parent.in_coyote_time = true
	animation_name = "walk"
	super()

func process_physics(delta: float) -> State:
	if Input.is_action_just_pressed('jump') and parent.is_on_floor():
		parent.apply_jump_foce()
		return jump_state
	parent.velocity.y += gravity * delta
	
	var direction := Input.get_axis("move_left","move_right")
		
	
	if direction == 0:
		return idle_state
	
	parent.move(direction)
	
	if !parent.is_on_floor():
		if !parent.in_coyote_time:
			return fall_state
		elif parent.coyote_timer.is_stopped():
			parent.start_coyote_time()
	if parent.is_on_floor():
		if !parent.coyote_timer.is_stopped():
			parent.stop_coyote_time()
	return null

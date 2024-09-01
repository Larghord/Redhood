class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var state_machine: Node = $StateMachine

const MOVE_SPEED: float = 200.0
const JUMP_FORCE: float = 650.0
const DEFAULT_MODIFIER: float = 1.0
const RUN_MODIFIER: float = DEFAULT_MODIFIER + 1.5
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.5

var in_coyote_time: bool = true
var in_jump_buffer: bool = false

var speed_modifier: float = DEFAULT_MODIFIER
var jump_modifier: float = DEFAULT_MODIFIER

var jump_buffer_timer:Timer = Timer.new()
var coyote_timer:Timer = Timer.new()

func _ready() -> void:
	create_coyote_timer()
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

#Move character
func move(direction) -> void:
	if direction:
		velocity.x = direction * (MOVE_SPEED * speed_modifier)
		sprite.scale.x = sign(velocity.x) * abs(sprite.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, (MOVE_SPEED * speed_modifier))
		
	move_and_slide()

#Makes character jump
func apply_jump_foce() -> void:
	velocity.y = -JUMP_FORCE * jump_modifier


#Coyote State Controls
func create_coyote_timer() -> void:
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.autostart = false
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.timeout.connect(_coyote_timedout)

func start_coyote_time() -> void:
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.start()
	

func stop_coyote_time() -> void:
	coyote_timer.stop()

func _coyote_timedout() -> void:
	in_coyote_time = false

#Jump Buffer Controls
func create_jump_buffer_timer() -> void:
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.autostart = false
	jump_buffer_timer.wait_time = JUMP_BUFFER_TIME

func start_jump_buffer_time() -> void:
	jump_buffer_timer.start()

func stop_jump_buffer_time() -> void:
	jump_buffer_timer.stop()

func jump_buffer_timedout() -> void:
	in_jump_buffer = false

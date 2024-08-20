class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var state_machine = $StateMachine

const MOVE_SPEED: float = 100
const JUMP_FORCE: float = 400.0
const DEFAULT_MODIFIER = 1

var speed_modifier = DEFAULT_MODIFIER

func _ready() -> void:
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func move(direction) -> void:
	if direction:
		velocity.x = direction * (MOVE_SPEED * speed_modifier)
		sprite.scale.x = sign(velocity.x) * abs(sprite.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, (MOVE_SPEED * speed_modifier))
		
	move_and_slide()

func apply_jump_foce() -> void:
	velocity.y = -JUMP_FORCE

func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")

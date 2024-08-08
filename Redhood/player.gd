extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -250.0
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x == 0.0:
		player_sprite.play("idle")
	elif velocity.x > 0 or velocity.x < 0:
		player_sprite.play("walk")
		player_sprite.scale.x = sign(velocity.x) * abs(player_sprite.scale.x);
	
	if velocity.y < 0.0 and not is_on_floor():
		player_sprite.play("jump")
	elif velocity.y > 0.0 and not is_on_floor():
		player_sprite.play("fall")
	
	move_and_slide()

extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var ray_cast_2d: RayCast2D = $RayCast2D

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
var speed_modifier = 1.0
var adjusted_speed = SPEED * speed_modifier


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
	if Input.is_action_pressed("crouch"):
		speed_modifier = 0.5
	else:
		speed_modifier = 1.0
	
	adjusted_speed = SPEED * speed_modifier
	if direction:
		velocity.x = direction * adjusted_speed
		player_sprite.scale.x = sign(velocity.x) * abs(player_sprite.scale.x);
	else:
		velocity.x = move_toward(velocity.x, 0, adjusted_speed)
		
	move_and_slide()

	if Input.is_action_pressed("crouch") and is_on_floor() and (velocity.x > 0.0 or velocity.x < 0.0):
		player_sprite.play("crouch_walk")
	elif Input.is_action_pressed("crouch") and is_on_floor():
		player_sprite.play("crouch")	
	elif velocity.x == 0.0:
		player_sprite.play("idle")
	elif velocity.x > 0 or velocity.x < 0:
		player_sprite.play("walk")
	
	if velocity.y < 0.0 and not is_on_floor():
		player_sprite.play("jump")
	elif velocity.y > 0.0 and not is_on_floor():
		player_sprite.play("fall")
	
	if is_on_wall() and is_on_floor() and direction:
		player_sprite.play("push_idle")
	elif is_on_wall() and not is_on_floor() and ray_cast_2d.is_colliding():
		player_sprite.play("wall_land")

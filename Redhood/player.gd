extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

var speed_modifier = 1.0
var adjusted_speed = SPEED * speed_modifier
var is_running = false
var is_crouching = false
var is_wall = false

func _physics_process(delta: float) -> void:
	
	if ray_cast_2d.is_colliding() or ray_cast_2d_2.is_colliding():
		is_wall = true
	else:
		is_wall = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("run") and is_on_floor():
		is_running = true
		speed_modifier += 0.5
	elif Input.is_action_just_released("run"):
		is_running = false
		speed_modifier += -0.5

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
		speed_modifier += -0.5
	elif Input.is_action_just_released("crouch"):
		is_crouching = false
		speed_modifier += 0.5
	
	adjusted_speed = SPEED * speed_modifier
	if direction:
		velocity.x = direction * adjusted_speed
		player_sprite.scale.x = sign(velocity.x) * abs(player_sprite.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0, adjusted_speed)
		
	move_and_slide()

	if Input.is_action_pressed("crouch") and is_on_floor() and (velocity.x > 0.0 or velocity.x < 0.0):
		player_sprite.play("crouch_walk")
	elif Input.is_action_pressed("crouch") and is_on_floor():
		player_sprite.play("crouch")	
	elif is_running and (velocity.x > 0.0 or velocity.x < 0.0):
		player_sprite.play("run")
	elif velocity.x == 0.0:
		player_sprite.play("idle")
	elif velocity.x > 0 or velocity.x < 0 and not is_running:
		player_sprite.play("walk")
	
	if velocity.y < 0.0 and not is_on_floor():
		player_sprite.play("jump")
	elif velocity.y > 0.0 and not is_on_floor():
		player_sprite.play("fall")
	
	if is_wall and is_on_floor() and direction:
		player_sprite.play("push_idle")
	elif is_wall and not is_on_floor() and is_wall:
		player_sprite.play("wall_land")

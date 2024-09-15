extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

enum wall_types {
	NORMAL,
	SLICK,
	STICKY,
	WALL_CONVEYOR,
}

@export_group("Wall Type")
@export var wall_type: wall_types

var wall_friction:float

func _ready() -> void:
	match wall_type:
		0:
			wall_friction = 100.0
		1:
			wall_friction = 500.0
		2:
			wall_friction = 0.0
		3:
			wall_friction = -1500.0


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_wall_stick"):
		body.set_wall_stick(true, Vector2(0.0,wall_friction))


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_wall_stick"):
		body.set_wall_stick(false, Vector2(0.0, wall_friction))

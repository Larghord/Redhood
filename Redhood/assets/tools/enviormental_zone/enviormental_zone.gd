extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export_group("Enviormental Friction")
@export var friction: Vector2 = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_external_forces"):
		body.set_external_forces(friction)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_external_forces"):
		body.set_external_forces(-friction)

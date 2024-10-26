extends Node2D
@onready var ambience: AkEvent2D = $ForrestSoundEvents/Ambience


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ambience.post_event()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

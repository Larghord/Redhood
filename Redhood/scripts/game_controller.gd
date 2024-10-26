extends Node2D
@onready var music: AkEvent2D = $Node/Music

func _ready() -> void: music.post_event()
 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().quit()
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()

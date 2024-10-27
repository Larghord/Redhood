extends Node2D
@onready var music_event: AkEvent2D = $Music/Music_Event

func _ready() -> void:music_event.post_event()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().quit()
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()

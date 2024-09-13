extends Node

@export var starting_state:State

var _current_state = null
var _last_state = null

func init(parent:Player) -> void:
	for child in get_children():
		child.parent = parent
	
	change_state(starting_state)

func change_state(new_state: State) -> void:
	if _current_state:
		_current_state.exit()
	
	_last_state = _current_state
	
	_current_state = new_state
	_current_state.enter()

# Pass through functions for the Player
func process_physics(delta: float) -> void:
	var new_state = _current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = _current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = _current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func get_last_state() -> State:
	return _last_state

func get_current_state() -> State:
	return _current_state

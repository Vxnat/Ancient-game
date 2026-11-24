class_name StateMachine
extends Node
## Manages active State child nodes for Player, Allies, Enemies, and Bosses.

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	var owner_entity := get_parent() as CharacterBody2D
	for child in get_children():
		if child is State:
			var state := child as State
			states[state.name.to_lower()] = state
			state.entity = owner_entity
			state.transition_requested.connect(_on_state_transition_requested)

	if initial_state != null:
		current_state = initial_state
		current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


func change_state(new_state_name: StringName) -> void:
	var key: String = String(new_state_name).to_lower()
	if not states.has(key):
		push_warning("StateMachine: State '%s' not found on %s." % [new_state_name, get_parent().name])
		return
	var next_state: State = states[key]
	if next_state == current_state:
		return
	if current_state != null:
		current_state.exit()
	current_state = next_state
	current_state.enter()


func _on_state_transition_requested(state: State, new_state_name: StringName) -> void:
	if state != current_state:
		return
	change_state(new_state_name)

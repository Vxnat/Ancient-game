class_name State
extends Node
## Base state for the node-based StateMachine.

signal transition_requested(state: State, new_state_name: StringName)

var entity: CharacterBody2D


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass

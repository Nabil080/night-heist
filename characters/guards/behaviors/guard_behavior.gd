class_name GuardBehavior
extends Node

## Base of every behavior. A behavior only decides WHERE the guard wants to go,
## the PathFollowComponent and the MovementComponent do the walking.

@export var speed_multiplier := 1.0
@export var can_turn_around := true
## When true the brain goes to Chase as soon as the thief is seen
@export var reacts_to_thief := true
@export var can_catch := true
@export var is_alert := false
@export var is_blind := false
@export var icon := ""
@export var animation_override := &""

@onready var guard: Guard = owner
@onready var brain: GuardBrain = get_parent()


func enter(_data: Dictionary) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func _go_to(cell: Vector2i) -> void:
	guard.path_follow_component.target_cell = cell


func _has_arrived() -> bool:
	var movement := guard.movement_component
	return movement.current_cell == guard.path_follow_component.target_cell and movement.current_direction == Vector2i.ZERO

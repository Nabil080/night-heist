class_name PathFollowComponent
extends Node

## Walks the owner toward a target cell, asking A* for the way on every new tile

signal target_changed(target: Vector2)

@export var movement_component: MovementComponent

var path: Array[Vector2i]
var can_turn_around := true
var target_cell := Vector2i.ZERO:
	set(val):
		if target_cell == val: return
		target_cell = val
		target_changed.emit(MapManager.cell_to_world(val))

var _last_cell := Vector2i(-1, -1)


func update() -> void:
	var cell := movement_component.current_cell

	if cell == target_cell:
		_last_cell = cell
		path.clear()
		if movement_component.has_reached_center():
			movement_component.stop()
		return

	# Check if we just entered a new tile, or if we have nowhere to go
	var is_stuck := movement_component.current_direction == Vector2i.ZERO or movement_component.is_at_end
	if cell != _last_cell or is_stuck:
		_last_cell = cell
		_on_enter_tile(cell)


func _on_enter_tile(cell: Vector2i) -> void:
	path = MapManager.find_path(cell, target_cell)
	if path.size() < 2:
		return

	var direction: Vector2i = path[1] - cell
	var current := movement_component.current_direction

	# Prevent reverse
	if not can_turn_around and not movement_component.is_at_end and current != Vector2i.ZERO and direction == -current:
		var perpendiculars := [
			Vector2i(-current.y, current.x),
			Vector2i(current.y, -current.x)
		]

		var valid := perpendiculars.filter(
			func(dir):
				return MapManager.is_walkable_for_guards(cell + dir)
		)
		if not valid.is_empty():
			direction = valid.pick_random()
		elif MapManager.is_walkable_for_guards(cell + current):
			return

	movement_component.requested_direction = direction

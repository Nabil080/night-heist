class_name MovementComponent
extends Node

## Moves its owner from cell to cell on the grid. The owner asks for a direction,
## the turn happens as soon as the next cell in that direction is free.

signal direction_changed(dir: Vector2i)
signal requested_direction_changed(dir: Vector2i)
signal movement_stopped

@export var speed := 50.0

## Debug menu: walk everywhere, but still stay inside the map
var ignores_walls := false

var current_direction := Vector2i.ZERO:
	set(val): current_direction = val; direction_changed.emit(val)
var requested_direction := Vector2i.ZERO:
	set(val): requested_direction = val; requested_direction_changed.emit(val)
var current_cell := Vector2i.ZERO:
	get: return MapManager.world_to_cell(owner.global_position)
var centered_position := Vector2.ZERO:
	get: return MapManager.cell_to_world(current_cell)
var is_at_end: bool:
	get: return _is_blocked(current_cell + current_direction) and has_reached_center()


## True once we are at the center of the cell, or just past it (a step can jump over it)
func has_reached_center() -> bool:
	var to_center: Vector2 = centered_position - owner.global_position
	return to_center.dot(Vector2(current_direction)) <= 0.5


func stop() -> void:
	if requested_direction != Vector2i.ZERO:
		requested_direction = Vector2i.ZERO
	if current_direction != Vector2i.ZERO:
		current_direction = Vector2i.ZERO


func update_movement(delta: float) -> void:
	_update_direction()
	if current_direction == Vector2i.ZERO:
		return

	if is_at_end:
		owner.global_position = centered_position
		movement_stopped.emit()
		return

	owner.global_position += Vector2(current_direction) * speed * delta

	# Slide back to the middle of the lane, so a turn taken a bit early still lines up
	if current_direction.x:
		owner.global_position.y = move_toward(owner.global_position.y, centered_position.y, speed * delta)
	elif current_direction.y:
		owner.global_position.x = move_toward(owner.global_position.x, centered_position.x, speed * delta)


func _is_blocked(cell: Vector2i) -> bool:
	return not MapManager.is_inside_map(cell) if ignores_walls else MapManager.is_wall_cell(cell)


func _update_direction() -> void:
	if requested_direction == Vector2i.ZERO or requested_direction == current_direction:
		return
	if _is_blocked(current_cell + requested_direction):
		return
	current_direction = requested_direction

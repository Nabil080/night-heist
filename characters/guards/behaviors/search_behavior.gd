class_name SearchBehavior
extends GuardBehavior

## Goes where the thief was last seen, looks around, tries a few spots nearby
## then gives up and comes back to the default behavior.

## Time spent looking in one direction
@export var look_time := 0.35
## How far the guard goes to check other spots
@export var search_radius := 4

var _time_left := 0.0
var _look_left := 0.0
var _has_looked := false
var _directions_to_check: Array[Vector2i] = []


func enter(data: Dictionary) -> void:
	_time_left = guard.difficulty.search_time
	_has_looked = false
	_directions_to_check.clear()
	_go_to(data.cell)


func update(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		brain.change_to(brain.default_behavior)
		return

	if not _has_arrived():
		return

	_look_left -= delta
	if _look_left > 0.0:
		return

	if _directions_to_check.is_empty():
		if _has_looked:
			_has_looked = false
			_go_to(MapManager.random_cell_near(guard.movement_component.current_cell, search_radius))
			return
		_list_directions()

	guard.look_towards(_directions_to_check.pop_front())
	_look_left = look_time


func _list_directions() -> void:
	_has_looked = true
	var cell := guard.movement_component.current_cell
	for direction: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		if not MapManager.is_wall_cell(cell + direction):
			_directions_to_check.append(direction)

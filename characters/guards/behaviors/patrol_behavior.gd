class_name PatrolBehavior
extends GuardBehavior

## Walks from marker to marker, the markers are the children of guard.patrol_route

var _waypoints: Array[Vector2i] = []
var _index := 0


func enter(_data: Dictionary) -> void:
	if _waypoints.is_empty():
		for marker: Marker2D in guard.patrol_route.get_children():
			_waypoints.append(MapManager.world_to_cell(marker.global_position))

	_index = _closest_waypoint()
	_go_to(_waypoints[_index])


func update(_delta: float) -> void:
	if _has_arrived():
		_index = (_index + 1) % _waypoints.size()
		_go_to(_waypoints[_index])


func _closest_waypoint() -> int:
	var cell := Vector2(guard.movement_component.current_cell)
	var closest := 0
	for i in _waypoints.size():
		if cell.distance_squared_to(_waypoints[i]) < cell.distance_squared_to(_waypoints[closest]):
			closest = i
	return closest

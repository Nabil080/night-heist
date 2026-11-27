class_name GuardLootBehavior
extends GuardBehavior

## Stays around the part of the map with the most loot left, so he moves as the
## thief empties the rooms. When everything is taken he goes guard the exit.

@export var post_radius := 3
@export var wait_time := 0.6

var _wait_left := 0.0


func enter(_data: Dictionary) -> void:
	_wait_left = 0.0
	_go_to(_pick_spot())


func update(delta: float) -> void:
	if not _has_arrived():
		return

	_wait_left -= delta
	if _wait_left <= 0.0:
		_wait_left = wait_time
		_go_to(_pick_spot())


func _pick_spot() -> Vector2i:
	var loot := guard.level.loot
	var post := loot.richest_cell() if loot.loot_left > 0 else guard.level.exit_door.cell
	return MapManager.random_cell_near(post, post_radius)

class_name TrackScentBehavior
extends GuardBehavior

## Follows the footprints of the thief. On every tile he moves to the neighbor
## with the freshest scent, so he walks the exact path of the thief. With no
## scent around, he sniffs the area, and wanders when there is really nothing.

## How far he can pick up a trail he isn't on
@export var sniff_radius := 8
@export var wander_radius := 6

var _last_cell := Vector2i(-1, -1)


func enter(_data: Dictionary) -> void:
	_last_cell = Vector2i(-1, -1)


func update(_delta: float) -> void:
	var cell := guard.movement_component.current_cell
	if cell == _last_cell and not _has_arrived():
		return
	_last_cell = cell

	var scent := guard.level.scent_trail
	var next_cell := scent.freshest_neighbor(cell)
	if next_cell == cell:
		next_cell = scent.freshest_near(cell, sniff_radius)
	if next_cell == cell:
		next_cell = MapManager.random_cell_near(cell, wander_radius)
	_go_to(next_cell)

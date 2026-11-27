class_name ChaseBehavior
extends GuardBehavior

## Runs after the thief. The guard keeps a short memory: he still knows where
## the thief went for a moment after losing sight of him, then starts searching.

var _memory_left := 0.0


func enter(_data: Dictionary) -> void:
	_memory_left = guard.difficulty.chase_memory
	var cell := guard.thief.current_cell
	_go_to(cell)
	EventBus.thief_spotted.emit(cell, guard)
	EventBus.chase_started.emit()


func exit() -> void:
	EventBus.chase_ended.emit()


func update(delta: float) -> void:
	var thief_cell := guard.thief.current_cell

	if guard.vision_component.can_see(thief_cell):
		_memory_left = guard.difficulty.chase_memory
	else:
		_memory_left -= delta
		if _memory_left <= 0.0:
			brain.change_to(&"Search", {"cell": thief_cell})
			return

	_go_to(thief_cell)

class_name StunnedBehavior
extends GuardBehavior

## Blinded by the smoke: can't see, can't catch and forgets what he was doing

var _time_left := 0.0


func enter(_data: Dictionary) -> void:
	_time_left = guard.difficulty.stun_time
	guard.movement_component.stop()
	_go_to(guard.movement_component.current_cell)


func update(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		brain.change_to(brain.default_behavior)

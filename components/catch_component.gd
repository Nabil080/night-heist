class_name CatchComponent
extends Area2D

## Catches the thief as soon as his area overlaps this one

var is_active := true


func _physics_process(_delta: float) -> void:
	if is_active and not DebugSettings.is_invincible and has_overlapping_areas():
		EventBus.thief_caught.emit()

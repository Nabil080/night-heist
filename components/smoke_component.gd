class_name SmokeComponent
extends Node

## Holds the smoke bombs of the thief and throws them

const SMOKE_CLOUD = preload("res://levels/smoke_cloud.tscn")

var count := 0:
	set(val):
		count = clampi(val, 0, Constants.MAX_SMOKE)
		EventBus.smoke_changed.emit(count)


func _ready() -> void:
	EventBus.smoke_collected.connect(func (): count += 1)


func throw() -> void:
	if DebugSettings.has_infinite_smoke:
		count = Constants.MAX_SMOKE
	if count <= 0:
		return

	count -= 1
	var cloud := SMOKE_CLOUD.instantiate()
	owner.get_parent().add_child(cloud)
	cloud.global_position = owner.global_position
	AudioManager.play_one_shot("SmokeDeploy")

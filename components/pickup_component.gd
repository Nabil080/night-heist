class_name PickupComponent
extends Node

## Grabs whatever is on the cell of its owner

var _loot_sound_index := 0


func check_cell(cell: Vector2i) -> void:
	if MapManager.is_loot_cell(cell):
		EventBus.points_scored.emit(MapManager.loot.take(cell))
		_loot_sound()

	elif MapManager.is_smoke_pickup_cell(cell):
		MapManager.smoke_pickups.erase_cell(cell)
		EventBus.points_scored.emit(Constants.SMOKE_PICKUP_POINTS)
		EventBus.smoke_collected.emit()
		AudioManager.play_one_shot("SmokePickup")


func _loot_sound() -> void:
	AudioManager.play_one_shot("Loot" + str(_loot_sound_index))
	_loot_sound_index = (_loot_sound_index + 1) % 2

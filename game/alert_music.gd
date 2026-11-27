class_name AlertMusic
extends Node

## Switches the music while at least one guard is chasing the thief

var _chasing_guards := 0


func _ready() -> void:
	EventBus.chase_started.connect(_on_chase_started)
	EventBus.chase_ended.connect(_on_chase_ended)
	EventBus.chase_reset.connect(func (): _chasing_guards = 0)


func _on_chase_started() -> void:
	_chasing_guards += 1
	if _chasing_guards == 1:
		AudioManager.play_one_shot("Spotted")
		AudioManager.play_clip("AlertLoop")


func _on_chase_ended() -> void:
	_chasing_guards = maxi(0, _chasing_guards - 1)
	if _chasing_guards == 0 and AudioManager.active_clip:
		AudioManager.play_clip("NightAmbience")

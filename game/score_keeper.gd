class_name ScoreKeeper
extends Node

## Keeps the score and saves the best one on disk

const SAVE_PATH := "user://save.cfg"

@export var hud: HUD

var high_score := 0:
	set(value):
		high_score = value
		hud.set_high_score(high_score)

var score := 0:
	set(value):
		score = maxi(0, value)
		hud.set_score(score)
		if score > high_score:
			high_score = score


func _ready() -> void:
	_load_high_score()
	EventBus.points_scored.connect(func (points): score += points)


func reset() -> void:
	score = 0


func reset_high_score() -> void:
	high_score = 0
	save_high_score()


func save_high_score() -> void:
	var config := ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.save(SAVE_PATH)


func _load_high_score() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		high_score = config.get_value("score", "high_score", 0)

class_name HUD
extends CanvasLayer

## Top bar: score, best score, room, loot left, lives and smoke bombs

const LIFE_TEXTURE = preload("res://interface/life_icon.tres")
const SMOKE_TEXTURE = preload("res://interface/smoke_icon.tres")
const MAX_ICONS := 3

@onready var score_value: Label = %ScoreValue
@onready var high_score_value: Label = %HighScoreValue
@onready var level_value: Label = %LevelValue
@onready var loot_value: Label = %LootValue

@onready var lives_container: HBoxContainer = %LivesContainer
@onready var smoke_container: HBoxContainer = %SmokeContainer


func _ready() -> void:
	EventBus.smoke_changed.connect(set_smoke)
	EventBus.loot_changed.connect(set_loot_left)


func set_score(score: int) -> void:
	score_value.text = str(score)

func set_high_score(high_score: int) -> void:
	high_score_value.text = str(high_score)

func set_level(level: int, total: int) -> void:
	level_value.text = "%d/%d" % [level, total]

func set_loot_left(loot_left: int) -> void:
	loot_value.text = str(loot_left) if loot_left > 0 else "EXIT"

func set_lives(amount: int) -> void:
	_fill(lives_container, LIFE_TEXTURE, amount)

func set_smoke(amount: int) -> void:
	_fill(smoke_container, SMOKE_TEXTURE, amount)


func _fill(container: HBoxContainer, texture: Texture2D, amount: int) -> void:
	for child in container.get_children():
		child.queue_free()

	# The debug menu can add a lot of them: one icon and a number, to keep the bar on screen
	var icons := amount if amount <= MAX_ICONS else 1
	for i in icons:
		var tex := TextureRect.new()
		tex.texture = texture
		container.add_child(tex)

	if amount > MAX_ICONS:
		var label := Label.new()
		label.text = "x%d" % amount
		container.add_child(label)

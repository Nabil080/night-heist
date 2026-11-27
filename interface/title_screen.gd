class_name TitleScreen
extends CanvasLayer

## First screen, waits for Space, Enter or a click

signal confirmed

@onready var high_score_label: Label = %HighScoreLabel


func open(high_score: int) -> void:
	high_score_label.text = "Best: %d" % high_score
	visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	# The click also gives the focus to the game on the itch.io page
	var is_click: bool = event is InputEventMouseButton and event.pressed
	if event.is_action_pressed("confirm") or is_click:
		get_viewport().set_input_as_handled()
		visible = false
		confirmed.emit()

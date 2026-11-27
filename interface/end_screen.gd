class_name EndScreen
extends CanvasLayer

## Win or lose screen with the final score

signal confirmed

@onready var title_label: Label = %TitleLabel
@onready var score_label: Label = %ScoreLabel


func open(has_won: bool, score: int, high_score: int) -> void:
	title_label.text = "Heist complete!" if has_won else "Busted!"
	score_label.text = "Score: %d\nBest: %d" % [score, high_score]
	visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	var is_click: bool = event is InputEventMouseButton and event.pressed
	if event.is_action_pressed("confirm") or event.is_action_pressed("restart") or is_click:
		get_viewport().set_input_as_handled()
		visible = false
		confirmed.emit()

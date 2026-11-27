class_name Banner
extends CanvasLayer

## Big message in the middle of the screen, between rooms

@onready var label: Label = %Label

var _message_id := 0


func show_message(message: String, duration: float) -> void:
	_message_id += 1
	var id := _message_id
	label.text = message
	visible = true
	await get_tree().create_timer(duration, false).timeout
	if id == _message_id:
		visible = false


func cancel() -> void:
	_message_id += 1
	visible = false

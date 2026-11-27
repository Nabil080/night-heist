class_name PauseScreen
extends CanvasLayer

## Pauses the tree. Esc or Space to resume, R to go back to the title

signal quit_requested
signal debug_requested

@onready var debug_button: Button = %DebugButton


func _ready() -> void:
	debug_button.focus_mode = Control.FOCUS_NONE
	debug_button.pressed.connect(func (): debug_requested.emit())


func open() -> void:
	visible = true
	get_tree().paused = true
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("pause") or event.is_action_pressed("confirm"):
		_close()
	elif event.is_action_pressed("restart"):
		_close()
		quit_requested.emit()


## Also used by the debug menu when it jumps to another room
func close() -> void:
	visible = false
	get_tree().paused = false


func _close() -> void:
	close()
	get_viewport().set_input_as_handled()

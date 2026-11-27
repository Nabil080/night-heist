class_name DebugToggle
extends Button

## A toggle button linked to a variable of DebugSettings, set the name in the inspector

@export var setting: StringName


var _title := ""


func _ready() -> void:
	_title = text
	button_pressed = DebugSettings.get(setting)
	_update_text()
	toggled.connect(func (is_on: bool):
		DebugSettings.set(setting, is_on)
		_update_text()
	)


func _update_text() -> void:
	text = ("[x] " if button_pressed else "[ ] ") + _title

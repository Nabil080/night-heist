class_name DebugSlider
extends VBoxContainer

## A named slider. With a setting it's linked to DebugSettings, else a tab drives it

signal value_changed(value: float)

@export var title := ""
@export var min_value := 0.0
@export var max_value := 1.0
@export var step := 0.1
@export var setting: StringName

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider


func _ready() -> void:
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.focus_mode = Control.FOCUS_NONE
	if setting:
		slider.value = DebugSettings.get(setting)
		value_changed.connect(func (value: float): DebugSettings.set(setting, value))
	_update_label(slider.value)

	slider.value_changed.connect(func (value: float):
		_update_label(value)
		value_changed.emit(value)
	)


## Moves the slider without telling anyone
func show_value(value: float) -> void:
	slider.set_value_no_signal(value)
	_update_label(value)


func _update_label(value: float) -> void:
	label.text = "%s: %s" % [title, snappedf(value, step)]

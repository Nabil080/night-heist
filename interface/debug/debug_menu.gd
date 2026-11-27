class_name DebugMenu
extends CanvasLayer

## Opens with Tab. Every tab is its own node with its own script

@export var game_flow: GameFlow

@onready var panel: Control = %Panel
@onready var tabs: TabContainer = %Tabs


func _ready() -> void:
	panel.visible = false
	tabs.get_tab_bar().focus_mode = Control.FOCUS_NONE


func toggle() -> void:
	panel.visible = not panel.visible


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		toggle()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug"):
		DebugSettings.show_paths = not DebugSettings.show_paths
		get_viewport().set_input_as_handled()
	elif DebugSettings.teleport_on_click and event is InputEventMouseButton and event.pressed:
		_teleport_thief_to_mouse()


func _teleport_thief_to_mouse() -> void:
	var level := game_flow.level
	if not level: return

	var cell := MapManager.world_to_cell(level.get_global_mouse_position())
	if MapManager.is_inside_map(cell) and not MapManager.is_wall_cell(cell):
		level.thief.teleport_to(cell)
		get_viewport().set_input_as_handled()

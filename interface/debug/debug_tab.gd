class_name DebugTab
extends ScrollContainer

## Base of the tabs of the debug menu

@onready var menu: DebugMenu = owner

var game: GameFlow:
	get: return menu.game_flow
var level: Level:
	get: return menu.game_flow.level


func _ready() -> void:
	# Keep the keyboard for the game, a focused button would eat the arrows and Space
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_remove_focus(self)


func _remove_focus(node: Node) -> void:
	if node is Control:
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children():
		_remove_focus(child)


## Most buttons need a level, they do nothing on the title screen
func _bind(button: Button, action: Callable) -> void:
	button.pressed.connect(func ():
		if level: action.call()
	)

class_name DebugViewTab
extends DebugTab

## Everything that changes what you see, and the flow of time


func _ready() -> void:
	super()
	%PauseGame.pressed.connect(func (): get_tree().paused = not get_tree().paused)
	%StepFrame.pressed.connect(_step_frame)


func _step_frame() -> void:
	get_tree().paused = false
	await get_tree().physics_frame
	await get_tree().physics_frame
	get_tree().paused = true

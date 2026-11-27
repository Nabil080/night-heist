class_name DebugInfoTab
extends DebugTab

## Live readout of what the game is doing

@onready var info_label: Label = %InfoLabel


func _process(_delta: float) -> void:
	if not menu.panel.visible: return

	var lines: Array[String] = ["FPS: %d" % Engine.get_frames_per_second(), "State: %s" % GameFlow.States.keys()[game.state]]
	if level:
		lines.append("Room: %d %s" % [game.level_index + 1, level.title])
		lines.append("Thief: %s" % level.thief.current_cell)
		lines.append("Loot left: %d" % level.loot.loot_left)
		lines.append("Lives: %d  Smoke: %d" % [game.lives, level.thief.smoke_component.count])
		lines.append("Spotted: %s" % level.was_spotted)
		lines.append("Speed: %d px/s" % level.difficulty.guard_speed)
		for guard: Guard in level.guards.get_children():
			lines.append("%s" % guard.name)
			lines.append(" %s %s to %s" % [guard.brain.current_behavior.name, guard.movement_component.current_cell, guard.path_follow_component.target_cell])
	info_label.text = "\n".join(lines)

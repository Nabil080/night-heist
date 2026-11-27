extends Node

## Runs the real game without a window and plays the thief with a small bot.
## godot --headless --path . tests/ai_test.tscn

const LEVEL_1 := "res://levels/level_1.tscn"
const LEVEL_2 := "res://levels/level_2.tscn"
const LEVEL_3 := "res://levels/level_3.tscn"

var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_patrol_moves_and_spots(LEVEL_1)
	await _test_tracker_follows_scent(LEVEL_2)
	await _test_warden_goes_to_richest_loot(LEVEL_3)
	await _test_guard_sees_only_through_open_cells(LEVEL_1)
	await _test_smoke_stuns(LEVEL_1)
	await _test_all_guards_keep_moving(LEVEL_3)
	await _test_loot_opens_door_and_escape(LEVEL_1)
	await _test_vent_teleports_thief(LEVEL_1)
	await _test_nobody_leaves_the_map(LEVEL_1)
	await _test_debug_menu()
	await _test_pause_and_debug_menu()
	await _test_leaving_a_wall(LEVEL_1)
	await _test_full_game_win()
	await _test_full_game_lose()
	print("RESULT failures=%d" % _failures)
	get_tree().quit(1 if _failures else 0)


func _check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		_failures += 1


func _load(path: String) -> Level:
	var level: Level = load(path).instantiate()
	add_child(level)
	return level


func _unload(level: Level) -> void:
	EventBus.chase_reset.emit()
	level.free()
	await get_tree().process_frame


## Counted in physics ticks: the guards move on ticks, and a busy machine
## can run fewer of them than the clock says
func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, true).timeout


func _guard_of_kind(level: Level, behavior: StringName) -> Guard:
	for guard: Guard in level.guards.get_children():
		if guard.brain.default_behavior == behavior:
			return guard
	return null


func _test_patrol_moves_and_spots(path: String) -> void:
	var level := _load(path)
	var guard := _guard_of_kind(level, &"Patrol")
	var start := guard.global_position
	level.start()
	level.thief.is_active = false
	await _seconds(2.0)
	_check(guard.global_position.distance_to(start) > 20.0, "patroller walks his route")
	_check(guard.brain.current_behavior.name == &"Patrol", "patroller stays in Patrol while he sees nothing")

	# Put the thief right in the flashlight
	var cell := guard.movement_component.current_cell
	var facing := guard.vision_component.facing
	level.thief.global_position = MapManager.cell_to_world(cell + facing * 2)
	await _seconds(0.1)
	_check(guard.brain.current_behavior.name == &"Chase", "patroller chases when the thief is in the light")

	# Hide the thief far away: memory runs out, then search, then back to patrol
	level.thief.global_position = MapManager.cell_to_world(Vector2i(12, 15))
	guard.global_position = MapManager.cell_to_world(Vector2i(1, 1))
	await _seconds(level.difficulty.chase_memory + 0.3)
	_check(guard.brain.current_behavior.name == &"Search", "patroller searches after losing the thief")
	await _seconds(level.difficulty.search_time + 0.3)
	_check(guard.brain.current_behavior.name == &"Patrol", "patroller gives up and goes back to patrol")
	await _unload(level)


func _test_tracker_follows_scent(path: String) -> void:
	var level := _load(path)
	var guard := _guard_of_kind(level, &"TrackScent")
	level.start()
	level.thief.is_active = false
	guard.vision_component.hearing_range = -1
	guard.vision_component.vision_range = 0

	# A fake trail going away from the tracker
	var cell := guard.movement_component.current_cell
	var trail: Array[Vector2i] = MapManager.find_path(cell, Vector2i(21, 5))
	for trail_cell in trail:
		EventBus.thief_moved.emit(trail_cell)
		await _seconds(0.02)
	await _seconds(trail.size() * 16.0 / guard.movement_component.speed + 0.5)
	_check(guard.movement_component.current_cell.distance_to(trail[-1]) <= 1.0, "tracker walks the trail until its fresh end (at %s, end %s)" % [guard.movement_component.current_cell, trail[-1]])
	await _unload(level)


func _test_warden_goes_to_richest_loot(path: String) -> void:
	var level := _load(path)
	var guard := _guard_of_kind(level, &"GuardLoot")
	level.thief.global_position = MapManager.cell_to_world(Vector2i(12, 7))
	level.start()
	level.thief.is_active = false
	guard.vision_component.hearing_range = -1
	guard.vision_component.vision_range = 0

	# Empty all the right half of the map
	for cell in level.loot.get_used_cells():
		if cell.x >= 10:
			level.loot.take(cell)
	var richest := level.loot.richest_cell()
	_check(richest.x < 10, "richest cell moved to the left side")
	guard.brain.change_to(&"GuardLoot")
	await _seconds(9.0)
	var distance := Vector2(guard.movement_component.current_cell).distance_to(richest)
	_check(distance <= 10.0, "warden came to the loot (distance %.1f)" % distance)
	await _unload(level)


func _test_guard_sees_only_through_open_cells(path: String) -> void:
	var level := _load(path)
	var guard := _guard_of_kind(level, &"Patrol")
	var vision := guard.vision_component
	for cell in vision.visible_cells:
		_check(not MapManager.is_wall_cell(cell) or MapManager.has_line_of_sight(guard.movement_component.current_cell, cell), "visible cell %s has a clear line" % cell)
	_check(not MapManager.has_line_of_sight(Vector2i(1, 1), Vector2i(1, 16)), "walls block the line of sight")
	await _unload(level)


func _test_smoke_stuns(path: String) -> void:
	var level := _load(path)
	var guard := _guard_of_kind(level, &"Patrol")
	level.start()
	level.thief.global_position = guard.global_position + Vector2(16, 0)
	level.thief.smoke_component.count = 1
	level.thief.smoke_component.throw()
	await _seconds(0.1)
	_check(guard.brain.current_behavior.name == &"Stunned", "smoke stuns a guard in range")
	_check(not guard.catch_component.is_active, "a stunned guard can't catch")
	var position := guard.global_position
	await _seconds(0.5)
	_check(guard.global_position == position, "a stunned guard doesn't move")
	await _unload(level)


func _test_all_guards_keep_moving(path: String) -> void:
	var level := _load(path)
	level.thief.is_active = false
	level.start()
	level.thief.is_active = false
	# Nobody should ever stand still for long, or walk in a wall
	var last_positions := {}
	var still_time := {}
	for guard: Guard in level.guards.get_children():
		guard.vision_component.vision_range = 0
		guard.vision_component.hearing_range = -1
		last_positions[guard] = guard.global_position
		still_time[guard] = 0.0
	var max_still := 0.0
	var in_wall := false
	for i in 200:
		await _seconds(0.1)
		for guard: Guard in level.guards.get_children():
			if MapManager.is_wall_cell(guard.movement_component.current_cell):
				in_wall = true
			still_time[guard] = 0.0 if guard.global_position != last_positions[guard] else still_time[guard] + 0.1
			max_still = maxf(max_still, still_time[guard])
			last_positions[guard] = guard.global_position
	_check(not in_wall, "no guard ever walks in a wall (20s)")
	_check(max_still < 4.0, "no guard gets stuck (longest stop %.1fs)" % max_still)
	await _unload(level)


func _test_loot_opens_door_and_escape(path: String) -> void:
	var level := _load(path)
	var escaped := [false]
	var on_escaped := func (): escaped[0] = true
	EventBus.thief_escaped.connect(on_escaped)
	level.start()
	_check(not level.exit_door.is_open, "door closed while loot is left")
	level.thief.global_position = level.exit_door.global_position
	await _seconds(0.2)
	_check(not escaped[0], "can't leave through a closed door")
	_check(level.thief.current_cell != level.exit_door.cell, "a thief on a closed door goes back to his start")
	for cell in level.loot.get_used_cells():
		level.loot.take(cell)
	_check(level.exit_door.is_open, "door opens when the loot is gone")
	level.thief.global_position = level.exit_door.global_position
	await _seconds(0.2)
	_check(escaped[0], "thief escapes through the open door")
	EventBus.thief_escaped.disconnect(on_escaped)
	await _unload(level)


func _test_vent_teleports_thief(path: String) -> void:
	var level := _load(path)
	level.start()
	var vent: Vent = level.get_node("Vents").get_child(0)
	level.thief.global_position = vent.global_position
	await _seconds(0.2)
	_check(level.thief.global_position.distance_to(vent.linked_vent.exit_point.global_position) < 8.0, "a vent sends the thief to the other side")
	_check(not MapManager.is_walkable_for_guards(MapManager.world_to_cell(vent.global_position)), "guards can't walk on a vent")
	await _unload(level)


func _test_nobody_leaves_the_map(path: String) -> void:
	var level := _load(path)
	var door := level.exit_door.cell
	_check(MapManager.is_wall_cell(door), "a closed door stops the thief")
	_check(MapManager.is_wall_cell(door + Vector2i.DOWN), "the cell under the door is blocked")
	_check(MapManager.is_wall_cell(Vector2i(-1, 7)), "the cell behind a vent is blocked")

	level.start()
	level.exit_door.open()
	_check(not MapManager.is_wall_cell(door), "an open door lets the thief in")
	level.thief.movement_component.requested_direction = Vector2i.DOWN
	level.thief.teleport_to(door + Vector2i.UP)
	level.thief.movement_component.requested_direction = Vector2i.DOWN
	var escaped := [false]
	var on_escaped := func (): escaped[0] = true
	EventBus.thief_escaped.connect(on_escaped)
	await _seconds(1.0)
	_check(escaped[0], "walking down into the open door ends the room")
	_check(MapManager.is_inside_map(level.thief.current_cell), "the thief stays inside the map")
	EventBus.thief_escaped.disconnect(on_escaped)
	await _unload(level)


func _test_pause_and_debug_menu() -> void:
	var game: GameFlow = load("res://game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	DebugSettings.skip_intro = true
	var menu: DebugMenu = game.debug_menu
	menu.get_node("%Room1").pressed.emit()
	await _seconds(0.1)
	await _press(&"pause")
	_check(get_tree().paused and game.pause_screen.visible, "the pause screen opens")
	game.pause_screen.debug_button.pressed.emit()
	_check(menu.panel.visible, "the pause screen button opens the debug menu")
	menu.get_node("%Room2").pressed.emit()
	_check(not get_tree().paused and not game.pause_screen.visible, "jumping to a room leaves the pause")
	_check(game.level_index == 1 and game.state == GameFlow.States.PLAYING, "the jump from the pause starts the room")

	game.lives = 12
	await get_tree().process_frame
	_check(game.hud.lives_container.get_child_count() == 2, "many lives show one icon and a number")
	DebugSettings.skip_intro = false
	EventBus.chase_reset.emit()
	get_tree().paused = false
	game.free()
	await get_tree().process_frame


func _test_leaving_a_wall(path: String) -> void:
	var level := _load(path)
	level.start()
	DebugSettings.walks_through_walls = true
	await _seconds(0.1)
	level.thief.teleport_to(Vector2i(2, 2))
	_check(MapManager.is_wall_cell(level.thief.current_cell), "the thief can stand in a wall with the cheat")
	await _seconds(0.1)
	_check(MapManager.is_wall_cell(level.thief.current_cell), "he stays there while the cheat is on")
	DebugSettings.walks_through_walls = false
	await _seconds(0.1)
	_check(not MapManager.is_wall_cell(level.thief.current_cell), "turning the cheat off brings him back on the floor")
	await _unload(level)


func _test_debug_menu() -> void:
	var game: GameFlow = load("res://game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	var menu: DebugMenu = game.get_node("DebugMenu")
	_check(not menu.panel.visible, "the debug menu starts closed")
	await _press(&"debug_menu")
	_check(menu.panel.visible, "Tab opens the debug menu")

	menu.get_node("%Room3").pressed.emit()
	_check(game.level_index == 2 and game.level != null and not game.title_screen.visible, "the menu jumps to room 3 from the title")
	menu.get_node("%Room2").pressed.emit()
	await _seconds(0.1)
	_check(game.level_index == 1 and game.state == GameFlow.States.INTRO, "jumping again during the intro works")
	await _seconds(1.8)
	_check(game.state == GameFlow.States.PLAYING and game.level.is_running, "the room starts once, after the last jump")

	var guards := game.level.guards
	var count := guards.get_child_count()
	menu.get_node("%SpawnWarden").pressed.emit()
	menu.get_node("%SpawnPatroller").pressed.emit()
	menu.get_node("%SpawnTracker").pressed.emit()
	await _seconds(0.5)
	_check(guards.get_child_count() == count + 3, "the menu spawns the three kinds of guard")
	var spawned: Guard = guards.get_child(count + 1)
	var start := spawned.global_position
	await _seconds(2.0)
	_check(spawned.global_position != start, "a spawned patroller walks")

	DebugSettings.is_invincible = true
	game.level.thief.global_position = spawned.global_position
	await _seconds(0.2)
	_check(game.state == GameFlow.States.PLAYING, "invincible: a guard can't catch the thief")
	DebugSettings.is_invincible = false

	menu.get_node("%AllChase").pressed.emit()
	game.level.thief.global_position = MapManager.cell_to_world(Vector2i(12, 13))
	menu.get_node("%StunAll").pressed.emit()
	_check(spawned.brain.current_behavior.name == &"Stunned", "the menu stuns every guard")
	menu.get_node("%RemoveAll").pressed.emit()
	await _seconds(0.1)
	_check(guards.get_child_count() == 0, "the menu removes every guard")

	var slider: DebugSlider = menu.get_node("%DifficultySliders/VisionRange")
	slider.slider.value = 9
	_check(game.level.difficulty.vision_range == 9, "a difficulty slider changes the level")
	_check((load("res://levels/difficulty/level_2.tres") as DifficultySettings).vision_range == 6, "the resource on disk stays the same")

	menu.get_node("%TakeAll").pressed.emit()
	_check(game.level.exit_door.is_open, "taking all the loot opens the door")
	menu.get_node("%ForceVictory").pressed.emit()
	_check(game.state == GameFlow.States.END and game.end_screen.visible, "the menu forces the ending")
	menu.get_node("%Room1").pressed.emit()
	_check(not game.end_screen.visible and game.level_index == 0, "the menu leaves the end screen")

	DebugSettings.skip_intro = true
	menu.get_node("%Restart").pressed.emit()
	_check(game.state == GameFlow.States.PLAYING, "skip intro starts the room right away")
	DebugSettings.skip_intro = false
	EventBus.chase_reset.emit()
	game.free()
	await get_tree().process_frame


func _press(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await _seconds(0.25)


func _test_full_game_win() -> void:
	var game: GameFlow = load("res://game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	_check(game.state == GameFlow.States.TITLE, "the game opens on the title screen")
	await _press(&"confirm")
	_check(game.state == GameFlow.States.INTRO and game.level != null, "confirm starts the first level")

	for i in game.levels.size():
		await _seconds(1.8)
		_check(game.state == GameFlow.States.PLAYING and game.level_index == i, "level %d is playing" % (i + 1))
		var score_before := game.score_keeper.score
		game.level.thief.global_position = game.level.exit_door.global_position
		for cell in game.level.loot.get_used_cells():
			game.level.loot.take(cell)
		await _seconds(0.2)
		_check(game.state == GameFlow.States.ESCAPED, "level %d is left through the door" % (i + 1))
		_check(game.score_keeper.score >= score_before + Constants.ESCAPE_BONUS, "escape gives a bonus")
		await _seconds(2.0)

	_check(game.state == GameFlow.States.END and game.end_screen.visible, "the third level ends the game")
	_check(game.end_screen.title_label.text == "Heist complete!", "the end screen shows a win")
	await _press(&"restart")
	_check(game.state == GameFlow.States.INTRO and game.level_index == 0 and game.score_keeper.score == 0, "restart goes back to level 1 with no score")
	await _seconds(1.8)
	EventBus.chase_reset.emit()
	game.free()
	await get_tree().process_frame


func _test_full_game_lose() -> void:
	var game: GameFlow = load("res://game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	await _press(&"confirm")
	await _seconds(1.8)

	var loot_before := game.level.loot.loot_left
	for life in Constants.START_LIVES:
		_check(game.lives == Constants.START_LIVES - life, "%d lives left" % game.lives)
		var guard: Guard = game.level.guards.get_child(0)
		game.level.thief.global_position = guard.global_position
		await _seconds(0.2)
		_check(game.state == GameFlow.States.CAUGHT, "touching a guard catches the thief")
		await _seconds(2.0)
		if life < Constants.START_LIVES - 1:
			await _seconds(1.8)
			_check(game.state == GameFlow.States.PLAYING, "the level restarts after a catch")
			_check(game.level.loot.loot_left <= loot_before, "the loot stays taken")

	_check(game.state == GameFlow.States.END and game.end_screen.title_label.text == "Busted!", "no lives left ends the game")
	await _press(&"pause")
	_check(game.state == GameFlow.States.END, "pause does nothing on the end screen")
	game.free()
	await get_tree().process_frame

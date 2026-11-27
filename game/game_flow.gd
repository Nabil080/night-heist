class_name GameFlow
extends Node

## The whole loop: title, level intro, play, caught or escaped, end screen

enum States { TITLE, INTRO, PLAYING, CAUGHT, ESCAPED, END }

@export var levels: Array[PackedScene]

@onready var level_holder: Node = %LevelHolder
@onready var score_keeper: ScoreKeeper = %ScoreKeeper
@onready var hud: HUD = %HUD
@onready var title_screen: TitleScreen = %TitleScreen
@onready var end_screen: EndScreen = %EndScreen
@onready var pause_screen: PauseScreen = %PauseScreen
@onready var banner: Banner = %Banner
@onready var debug_menu: DebugMenu = %DebugMenu

var state := States.TITLE
var level: Level
var level_index := 0

## Goes up when the debug menu jumps around, so a waiting step knows it's outdated
var _run_id := 0

var lives := Constants.START_LIVES:
	set(val):
		lives = maxi(0, val)
		hud.set_lives(lives)


func _ready() -> void:
	EventBus.thief_caught.connect(_on_thief_caught)
	EventBus.thief_escaped.connect(_on_thief_escaped)
	title_screen.confirmed.connect(_new_game)
	end_screen.confirmed.connect(_new_game)
	pause_screen.quit_requested.connect(_back_to_title)
	pause_screen.debug_requested.connect(debug_menu.toggle)
	_back_to_title()


func _unhandled_input(event: InputEvent) -> void:
	if state == States.PLAYING and event.is_action_pressed("pause"):
		pause_screen.open()


func _back_to_title() -> void:
	_run_id += 1
	state = States.TITLE
	_free_level()
	AudioManager.stop_clip()
	hud.visible = false
	title_screen.open(score_keeper.high_score)


func _new_game() -> void:
	_run_id += 1
	AudioManager.play_one_shot("Confirm")
	score_keeper.reset()
	hud.visible = true
	lives = Constants.START_LIVES
	level_index = 0
	_load_level(Constants.START_SMOKE)
	_play_intro()


## Debug menu
func jump_to_level(index: int) -> void:
	_run_id += 1
	pause_screen.close()
	banner.cancel()
	title_screen.visible = false
	end_screen.visible = false
	hud.visible = true
	level_index = index
	_load_level(level.thief.smoke_component.count if level else Constants.START_SMOKE)
	_play_intro()


## Debug menu
func force_end(has_won: bool) -> void:
	_run_id += 1
	pause_screen.close()
	banner.cancel()
	title_screen.visible = false
	hud.visible = true
	if level:
		level.freeze()
	_end_game(has_won)


func _load_level(smoke: int) -> void:
	_free_level()
	level = levels[level_index].instantiate()
	level_holder.add_child(level)
	level.thief.smoke_component.count = smoke
	hud.set_level(level_index + 1, levels.size())
	hud.set_loot_left(level.loot.loot_left)


func _free_level() -> void:
	if not level: return
	EventBus.chase_reset.emit()
	level.free()
	level = null


func _play_intro() -> void:
	state = States.INTRO
	var run_id := _run_id
	if not DebugSettings.skip_intro:
		await banner.show_message("Room %d\n%s" % [level_index + 1, level.title], 1.6)
	if run_id != _run_id: return

	state = States.PLAYING
	AudioManager.play_clip("NightAmbience")
	level.start()


func _on_thief_caught() -> void:
	if state != States.PLAYING: return
	state = States.CAUGHT
	level.freeze()
	EventBus.chase_reset.emit()
	var run_id := _run_id
	await level.thief.play_caught()
	if run_id != _run_id: return

	lives -= 1
	if lives == 0:
		_end_game(false)
		return
	level.reset_actors()
	_play_intro()


func _on_thief_escaped() -> void:
	if state != States.PLAYING: return
	state = States.ESCAPED
	level.freeze()
	EventBus.chase_reset.emit()
	AudioManager.stop_clip()
	AudioManager.play_one_shot("LevelDone")

	var bonus := Constants.ESCAPE_BONUS
	var message := "Room cleared!\n+%d"
	if not level.was_spotted:
		bonus += Constants.STEALTH_BONUS
		message = "Never seen!\n+%d"
	EventBus.points_scored.emit(bonus)
	lives += 1
	var run_id := _run_id
	await banner.show_message((message + "
+1 life") % bonus, 1.8)
	if run_id != _run_id: return

	level_index += 1
	if level_index >= levels.size():
		_end_game(true)
		return
	_load_level(level.thief.smoke_component.count)
	_play_intro()


func _end_game(has_won: bool) -> void:
	state = States.END
	AudioManager.stop_clip()
	AudioManager.play_one_shot("Victory" if has_won else "GameOver")
	score_keeper.save_high_score()
	end_screen.open(has_won, score_keeper.score, score_keeper.high_score)

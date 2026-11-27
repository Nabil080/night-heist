class_name DebugRoomTab
extends DebugTab

## Jump between the rooms, force an ending, change the difficulty

@onready var sliders: Node = %DifficultySliders


func _ready() -> void:
	super()
	%Room1.pressed.connect(func (): game.jump_to_level(0))
	%Room2.pressed.connect(func (): game.jump_to_level(1))
	%Room3.pressed.connect(func (): game.jump_to_level(2))
	%ForceVictory.pressed.connect(func (): game.force_end(true))
	%ForceGameOver.pressed.connect(func (): game.force_end(false))

	_bind(%Restart, func (): game.jump_to_level(game.level_index))
	_bind(%TakeHalf, func (): level.loot.take_many(level.loot.loot_left / 2 + 1))
	_bind(%TakeAll, func (): level.loot.take_many(level.loot.loot_left))
	_bind(%OpenDoor, func (): level.exit_door.open())
	_bind(%WinRoom, func (): EventBus.thief_escaped.emit())
	_bind(%LoseLife, func (): EventBus.thief_caught.emit())
	%ResetBest.pressed.connect(func (): game.score_keeper.reset_high_score())

	_bind(%DifficultyEasy, func (): _load_difficulty(1))
	_bind(%DifficultyNormal, func (): _load_difficulty(2))
	_bind(%DifficultyHard, func (): _load_difficulty(3))

	for slider: DebugSlider in sliders.get_children():
		slider.value_changed.connect(func (value: float):
			if not level: return
			level.difficulty.set(slider.name.to_snake_case(), value)
			level.apply_difficulty()
		)


func _process(_delta: float) -> void:
	if not level or not menu.panel.visible: return
	for slider: DebugSlider in sliders.get_children():
		slider.show_value(level.difficulty.get(slider.name.to_snake_case()))


func _load_difficulty(number: int) -> void:
	level.difficulty = load("res://levels/difficulty/level_%d.tres" % number).duplicate()
	level.apply_difficulty()

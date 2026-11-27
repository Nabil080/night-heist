class_name Guard
extends Node2D

## Shared by every guard. The brain decides, the components walk, look and catch.

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var state_icon: Label = %StateIcon
@onready var behavior_label: Label = %BehaviorLabel
@onready var debug: Node2D = %Debug

@onready var movement_component: MovementComponent = %MovementComponent
@onready var path_follow_component: PathFollowComponent = %PathFollowComponent
@onready var vision_component: VisionComponent = %VisionComponent
@onready var catch_component: CatchComponent = %CatchComponent
@onready var brain: GuardBrain = %GuardBrain

## How fast this kind of guard walks compared to the speed of the level
@export var speed_multiplier := 1.0
@export var patrol_route: Node2D

var level: Level
var thief: Thief
var difficulty: DifficultySettings
var is_paused := true

var _start_position: Vector2


func _ready() -> void:
	_start_position = global_position
	movement_component.direction_changed.connect(_play_animation)


func setup(new_level: Level) -> void:
	level = new_level
	thief = level.thief
	difficulty = level.difficulty
	reset()
	apply_difficulty()


func apply_difficulty() -> void:
	vision_component.vision_range = difficulty.vision_range
	brain.update_speed()


func reset() -> void:
	global_position = _start_position
	movement_component.stop()
	path_follow_component.target_cell = movement_component.current_cell
	is_paused = true
	brain.start()
	sprite.pause()


func set_paused(paused: bool) -> void:
	is_paused = paused
	catch_component.is_active = not paused and brain.current_behavior.can_catch
	if paused: sprite.pause()
	else: sprite.play()


func stun() -> void:
	brain.change_to(&"Stunned")


## Debug menu: leaves through the brain, a chasing guard must end his chase
func remove() -> void:
	brain.start()
	if patrol_route:
		patrol_route.queue_free()
	queue_free()


func look_towards(dir: Vector2i) -> void:
	vision_component.facing = dir
	_play_animation(dir)
	sprite.pause()


func _physics_process(delta: float) -> void:
	debug.visible = DebugSettings.show_paths
	behavior_label.visible = DebugSettings.show_states
	behavior_label.text = brain.current_behavior.name

	if is_paused or DebugSettings.guards_frozen: return

	brain.update(delta)
	path_follow_component.update()
	movement_component.update_movement(delta * DebugSettings.guard_speed)


func _play_animation(dir: Vector2i) -> void:
	if brain.current_behavior and brain.current_behavior.animation_override:
		sprite.play(brain.current_behavior.animation_override)
		return

	match dir:
		Vector2i.UP: sprite.play("up")
		Vector2i.RIGHT: sprite.play("right")
		Vector2i.DOWN: sprite.play("down")
		Vector2i.LEFT: sprite.play("left")
		_: sprite.pause()

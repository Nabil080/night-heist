class_name GuardBrain
extends Node

## State machine: each child node is a behavior and only one runs at a time.
## The kinds of guard only differ by the behavior they come back to.

signal behavior_changed(behavior: GuardBehavior)

@export var default_behavior := &"Patrol"

@onready var guard: Guard = owner

var current_behavior: GuardBehavior


func _ready() -> void:
	EventBus.thief_spotted.connect(_on_thief_spotted)


func start() -> void:
	change_to(default_behavior)


func update(delta: float) -> void:
	if current_behavior.reacts_to_thief and guard.vision_component.can_see(guard.thief.current_cell):
		change_to(&"Chase")
		return

	current_behavior.update(delta)


func change_to(behavior_name: StringName, data := {}) -> void:
	if current_behavior:
		current_behavior.exit()

	current_behavior = get_node(NodePath(behavior_name))

	guard.path_follow_component.can_turn_around = current_behavior.can_turn_around
	update_speed()
	guard.catch_component.is_active = current_behavior.can_catch and not guard.is_paused
	guard.vision_component.is_alert = current_behavior.is_alert
	guard.vision_component.is_blind = current_behavior.is_blind
	guard.state_icon.text = current_behavior.icon

	current_behavior.enter(data)
	guard._play_animation(guard.vision_component.facing)
	behavior_changed.emit(current_behavior)


func update_speed() -> void:
	guard.movement_component.speed = guard.difficulty.guard_speed * guard.speed_multiplier * current_behavior.speed_multiplier


## Another guard saw the thief: everyone close enough comes to help
func _on_thief_spotted(cell: Vector2i, spotted_by: Guard) -> void:
	if spotted_by == guard or guard.is_paused or not current_behavior.reacts_to_thief:
		return

	var distance := cell - guard.movement_component.current_cell
	if absi(distance.x) + absi(distance.y) <= guard.difficulty.alarm_radius:
		change_to(&"Search", {"cell": cell})

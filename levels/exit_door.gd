class_name ExitDoor
extends Node2D

## Closed until all the loot is taken, then the thief can leave

const OPEN_REGION := Rect2(16, 0, 16, 16)

@onready var sprite: Sprite2D = $Sprite2D
@onready var door_area: Area2D = $DoorArea
@onready var blink_component: BlinkComponent = $Sprite2D/BlinkComponent

var cell: Vector2i:
	get: return MapManager.world_to_cell(global_position)
var is_open := false


func _ready() -> void:
	EventBus.all_loot_collected.connect(open)


func _physics_process(_delta: float) -> void:
	if is_open and door_area.has_overlapping_areas():
		is_open = false
		EventBus.thief_escaped.emit()


func open() -> void:
	if is_open: return

	is_open = true
	MapManager.open_cell(cell)
	sprite.region_rect = OPEN_REGION
	blink_component.start()
	AudioManager.play_one_shot("ExitOpen")

class_name Vent
extends Node2D

## Shortcut for the thief only: the guards can't follow and the scent trail breaks

@export var linked_vent: Vent
@export var exit_direction := Vector2i.RIGHT

@onready var vent_area: Area2D = $VentArea
@onready var exit_point: Marker2D = $ExitPoint

func _ready() -> void:
	exit_point.position = Vector2(exit_direction) * MapManager.TILE_SIZE
	vent_area.area_entered.connect(func (area: Area2D):
		area.owner.global_position = linked_vent.exit_point.global_position
	)

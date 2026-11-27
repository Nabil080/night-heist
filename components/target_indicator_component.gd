class_name TargetIndicatorComponent
extends Node2D

## Debug view: four corners around the cell the guard is walking to

@export var _enabled := true:
	set(val): _enabled = val; visible = val
@export var color := Color.WHITE
@export var _path_follow_component: PathFollowComponent

var _width := 2
var _offset := MapManager.TILE_CENTER
var _corner_points := PackedVector2Array([
	Vector2(-_width, -_width),
	Vector2(-_width, _width),
	Vector2(0, _width),
	Vector2(0, 0),
	Vector2(_width, 0),
	Vector2(_width, -_width),
])


func _ready() -> void:
	modulate = color
	z_index = 1
	_path_follow_component.target_changed.connect(func (target: Vector2):
		global_position = MapManager.cell_to_world(MapManager.world_to_cell(target))
	)
	_create_corners()


func _create_corners() -> void:
	var corners := [
		Vector2(-_offset, -_offset),
		Vector2(-_offset, _offset),
		Vector2(_offset, _offset),
		Vector2(_offset, -_offset),
	]
	for i in corners.size():
		var polygon := Polygon2D.new()
		polygon.polygon = _corner_points
		polygon.position = corners[i]
		polygon.rotation = deg_to_rad(-90 * i)
		add_child(polygon)

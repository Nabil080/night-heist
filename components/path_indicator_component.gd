class_name PathIndicatorComponent
extends Node2D

## Debug view: draws the path the guard wants to follow

@export var _enabled := true:
	set(val): _enabled = val; visible = val
@export var color := Color.WHITE
@export var _path_follow_component: PathFollowComponent

var _width := 2


func _ready() -> void:
	modulate = color
	z_index = -1
	_path_follow_component.target_changed.connect(queue_redraw.unbind(1))


func _process(_delta: float) -> void:
	if is_visible_in_tree():
		queue_redraw()


func _draw() -> void:
	var path := _path_follow_component.path
	for i in range(path.size() - 1):
		var from := to_local(MapManager.cell_to_world(path[i]))
		var to := to_local(MapManager.cell_to_world(path[i + 1]))
		draw_line(from, to, color, _width)

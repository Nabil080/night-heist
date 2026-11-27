class_name VisionComponent
extends Node2D

## The flashlight of a guard. Works on the grid: a cell is visible when it's in
## front of the guard, inside a cone, with no wall in the way.

@export var movement_component: MovementComponent
@export var calm_color := Color(1.0, 0.92, 0.55, 0.22)
@export var alert_color := Color(1.0, 0.25, 0.2, 0.3)
## Cells around the guard where he notices the thief, even from behind
@export var hearing_range := 1

var vision_range := 4:
	set(val): vision_range = val; _refresh()
var facing := Vector2i.DOWN:
	set(val): facing = val; _refresh()
var is_alert := false:
	set(val): is_alert = val; queue_redraw()
var is_blind := false:
	set(val): is_blind = val; _refresh()
var visible_cells: Array[Vector2i] = []

var _last_cell := Vector2i(-1, -1)


func _ready() -> void:
	# Draw in world coordinates, the light must not move with the sprite between two cells
	top_level = true
	global_position = Vector2.ZERO
	movement_component.direction_changed.connect(func (dir: Vector2i):
		if dir != Vector2i.ZERO: facing = dir
	)


func _physics_process(_delta: float) -> void:
	visible = DebugSettings.show_flashlights
	var cell := movement_component.current_cell
	if cell != _last_cell:
		_last_cell = cell
		_refresh()


func can_see(target_cell: Vector2i) -> bool:
	if is_blind or DebugSettings.guards_blind or DebugSettings.is_invisible:
		return false

	var distance := target_cell - movement_component.current_cell
	if absi(distance.x) + absi(distance.y) <= hearing_range:
		return true
	return target_cell in visible_cells


func _refresh() -> void:
	visible_cells.clear()
	queue_redraw()
	if is_blind or not is_node_ready() or not MapManager.walls:
		return

	var origin := movement_component.current_cell
	var side_axis := Vector2i(facing.y, facing.x)
	for forward in range(1, vision_range + 1):
		var width := ceili(forward * 0.5) - 1
		for side in range(-width, width + 1):
			var cell := origin + facing * forward + side_axis * side
			if MapManager.has_line_of_sight(origin, cell):
				visible_cells.append(cell)


func _draw() -> void:
	var color := alert_color if is_alert else calm_color
	var size := Vector2.ONE * MapManager.TILE_SIZE
	for cell in visible_cells:
		var top_left := MapManager.cell_to_world(cell) - size / 2.0
		draw_rect(Rect2(top_left, size), color)

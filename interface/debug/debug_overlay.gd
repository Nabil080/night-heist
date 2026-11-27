class_name DebugOverlay
extends Node2D

## Draws the grid of the A*: blocked cells in red, the others with an outline

@export var solid_color := Color(1.0, 0.1, 0.1, 0.3)
@export var line_color := Color(0.4, 1.0, 1.0, 0.25)


func _process(_delta: float) -> void:
	visible = DebugSettings.show_grid and MapManager.astar != null and is_instance_valid(MapManager.walls)
	if visible:
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(MapManager.walls): return

	var region := MapManager.astar.region
	var size := Vector2.ONE * MapManager.TILE_SIZE
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var cell := Vector2i(x, y)
			var rect := Rect2(MapManager.cell_to_world(cell) - size / 2.0, size)
			if MapManager.astar.is_point_solid(cell):
				draw_rect(rect, solid_color)
			else:
				draw_rect(rect, line_color, false)

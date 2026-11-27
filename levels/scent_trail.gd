class_name ScentTrail
extends Node2D

## Remembers when the thief walked on each cell and draws fading footprints

@export var color := Color(0.55, 1.0, 0.65, 0.5)

var lifetime := 5.0

var _clock := 0.0
var _scents: Dictionary[Vector2i, float] = {}


func _ready() -> void:
	EventBus.thief_moved.connect(func (cell: Vector2i): _scents[cell] = _clock)


func _process(delta: float) -> void:
	visible = DebugSettings.show_footprints
	_clock += delta
	for cell in _scents.keys():
		if _clock - _scents[cell] > lifetime:
			_scents.erase(cell)
	queue_redraw()


func clear() -> void:
	_scents.clear()


func clear_around(center: Vector2i, radius: int) -> void:
	for cell in _scents.keys():
		if Vector2(cell - center).length() <= radius:
			_scents.erase(cell)


## Returns the cell itself when no neighbor smells stronger
func freshest_neighbor(cell: Vector2i) -> Vector2i:
	var best_cell := cell
	var best_time: float = _scents.get(cell, -1.0)
	for direction: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		var time: float = _scents.get(cell + direction, -1.0)
		if time > best_time and MapManager.is_walkable_for_guards(cell + direction):
			best_time = time
			best_cell = cell + direction
	return best_cell


## Returns the center when there is no scent in the radius
func freshest_near(center: Vector2i, radius: int) -> Vector2i:
	var best_cell := center
	var best_time := -1.0
	for cell in _scents:
		var distance: Vector2i = cell - center
		if absi(distance.x) + absi(distance.y) <= radius and _scents[cell] > best_time:
			best_time = _scents[cell]
			best_cell = cell
	return best_cell


func _draw() -> void:
	for cell in _scents:
		var strength: float = 1.0 - (_clock - _scents[cell]) / lifetime
		var center := to_local(MapManager.cell_to_world(cell))
		var print_color := Color(color, color.a * strength)
		draw_rect(Rect2(center + Vector2(-3, 1), Vector2(2, 2)), print_color)
		draw_rect(Rect2(center + Vector2(1, -2), Vector2(2, 2)), print_color)

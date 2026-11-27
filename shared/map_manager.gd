class_name GlobalMapManager
extends Node

## The grid of the current room: walls, loot, line of sight and A* pathfinding

const TILE_SIZE := 16
const TILE_CENTER := 8

var background: TileMapLayer
var walls: TileMapLayer
var loot: LootLayer
var smoke_pickups: TileMapLayer
var astar: AStarGrid2D

var _closed_cells: Dictionary[Vector2i, bool] = {}

func configure(background_layer: TileMapLayer, walls_layer: TileMapLayer, loot_layer: LootLayer, smoke_layer: TileMapLayer) -> void:
	background = background_layer
	walls = walls_layer
	loot = loot_layer
	smoke_pickups = smoke_layer
	_closed_cells.clear()

	astar = AStarGrid2D.new()
	astar.region = background.get_used_rect()
	astar.cell_size = walls.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	for cell in walls.get_used_cells():
		if astar.is_in_boundsv(cell):
			astar.set_point_solid(cell, true)

## Cells the guards can't walk on, but the thief can (vents, exit door)
func block_for_guards(cell: Vector2i) -> void:
	astar.set_point_solid(cell, true)

## A closed cell stops everyone like a wall, until it opens (exit door)
func close_cell(cell: Vector2i) -> void:
	_closed_cells[cell] = true

func open_cell(cell: Vector2i) -> void:
	_closed_cells.erase(cell)

#region converters

func world_to_cell(global_pos: Vector2) -> Vector2i:
	var local := walls.to_local(global_pos)
	return walls.local_to_map(local)

func cell_to_world(cell: Vector2i) -> Vector2:
	var local := walls.map_to_local(cell)
	return walls.to_global(local)

#endregion

#region checkers

## Everything outside of the floor counts as a wall, nobody can leave the map
func is_wall_cell(cell: Vector2i) -> bool:
	return walls.get_cell_source_id(cell) != -1 or not is_inside_map(cell) or _closed_cells.has(cell)

func is_inside_map(cell: Vector2i) -> bool:
	return background.get_used_rect().has_point(cell)

func is_wall_world(global_pos: Vector2) -> bool:
	return is_wall_cell(world_to_cell(global_pos))

func is_loot_cell(cell: Vector2i) -> bool:
	return loot.get_cell_source_id(cell) != -1

func is_smoke_pickup_cell(cell: Vector2i) -> bool:
	return smoke_pickups.get_cell_source_id(cell) != -1

func is_walkable_for_guards(cell: Vector2i) -> bool:
	return astar.is_in_boundsv(cell) and not astar.is_point_solid(cell)

## Draws a straight line between two cells and stops at the first wall
func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	var steps := maxi(absi(to.x - from.x), absi(to.y - from.y))
	var previous := from
	for i in range(1, steps + 1):
		var cell := Vector2i(Vector2(from).lerp(Vector2(to), float(i) / steps).round())
		if is_wall_cell(cell):
			return false
		# A diagonal step can't slip between the corners of two walls
		if is_wall_cell(Vector2i(cell.x, previous.y)) or is_wall_cell(Vector2i(previous.x, cell.y)):
			return false
		previous = cell
	return true

#endregion


#region pathfinding


func find_path(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	# Partial path: if the target can't be reached, get as close as possible
	return astar.get_id_path(from_cell, to_cell, true)


func random_cell_near(center: Vector2i, radius: int) -> Vector2i:
	var cells: Array[Vector2i] = []
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var cell := Vector2i(x, y)
			if is_walkable_for_guards(cell):
				cells.append(cell)

	if cells.is_empty():
		return center
	return cells.pick_random()


#endregion

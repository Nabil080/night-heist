class_name LootLayer
extends TileMapLayer

## The loot of the level, a tile disappears when the thief takes it

const GEM_ATLAS_X := 6
const RICHEST_RADIUS := 3

var loot_left := 0


func _ready() -> void:
	loot_left = get_used_cells().size()


func take(cell: Vector2i) -> int:
	var points := Constants.GEM_POINTS if get_cell_atlas_coords(cell).x == GEM_ATLAS_X else Constants.COIN_POINTS
	erase_cell(cell)
	loot_left -= 1
	EventBus.loot_changed.emit(loot_left)
	if loot_left == 0:
		EventBus.all_loot_collected.emit()
	return points


## Debug menu
func take_many(amount: int) -> void:
	var cells := get_used_cells()
	cells.shuffle()
	for i in mini(amount, cells.size()):
		take(cells[i])


## The cell with the most loot around it
func richest_cell() -> Vector2i:
	var best_cell := Vector2i.ZERO
	var best_count := -1
	for cell in get_used_cells():
		var count := 0
		for x in range(-RICHEST_RADIUS, RICHEST_RADIUS + 1):
			for y in range(-RICHEST_RADIUS, RICHEST_RADIUS + 1):
				if get_cell_source_id(cell + Vector2i(x, y)) != -1:
					count += 1
		if count > best_count:
			best_count = count
			best_cell = cell
	return best_cell

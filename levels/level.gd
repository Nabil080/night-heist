class_name Level
extends Node2D

## One room of the museum: holds the map, the thief and the guards

@export var title := ""
@export var difficulty: DifficultySettings

@onready var background: TileMapLayer = %Background
@onready var walls: TileMapLayer = %Walls
@onready var loot: LootLayer = %Loot
@onready var smoke_pickups: TileMapLayer = %SmokePickups
@onready var scent_trail: ScentTrail = %ScentTrail
@onready var exit_door: ExitDoor = %ExitDoor
@onready var thief: Thief = %Thief
@onready var guards: Node2D = %Guards

var is_running := false

## Stays false if no guard saw the thief, gives a bonus at the end
var was_spotted := false


func _ready() -> void:
	# Children are ready before their parent, so the map is configured here
	MapManager.configure(background, walls, loot, smoke_pickups)
	MapManager.block_for_guards(exit_door.cell)
	MapManager.close_cell(exit_door.cell)
	for vent in $Vents.get_children():
		MapManager.block_for_guards(MapManager.world_to_cell(vent.global_position))

	# The debug menu can change it, the resource on disk must stay the same
	difficulty = difficulty.duplicate()
	scent_trail.lifetime = difficulty.scent_lifetime
	EventBus.thief_spotted.connect(func (_cell, _guard): was_spotted = true)

	for guard: Guard in guards.get_children():
		guard.setup(self)


func start() -> void:
	is_running = true
	BlinkComponent.is_active = true
	thief.is_active = true
	for guard: Guard in guards.get_children():
		guard.set_paused(false)


func freeze() -> void:
	is_running = false
	BlinkComponent.is_active = false
	thief.is_active = false
	for guard: Guard in guards.get_children():
		guard.set_paused(true)


## After a catch: everyone goes back to their spot but the loot stays taken
func reset_actors() -> void:
	thief.reset()
	scent_trail.clear()
	for guard: Guard in guards.get_children():
		guard.reset()


func apply_difficulty() -> void:
	scent_trail.lifetime = difficulty.scent_lifetime
	for guard: Guard in guards.get_children():
		guard.apply_difficulty()


## Debug menu: adds a guard away from the thief, with a patrol route of his own
func spawn_guard(guard_scene: PackedScene) -> void:
	var cell := MapManager.random_cell_near(thief.current_cell, 30)
	while Vector2(cell - thief.current_cell).length() < 6.0:
		cell = MapManager.random_cell_near(thief.current_cell, 30)

	var guard: Guard = guard_scene.instantiate()
	guard.position = guards.to_local(MapManager.cell_to_world(cell))
	guard.patrol_route = _make_random_route(cell)
	guards.add_child(guard)
	guard.setup(self)
	if is_running:
		guard.set_paused(false)


func _make_random_route(start_cell: Vector2i) -> Node2D:
	var route := Node2D.new()
	$PatrolRoutes.add_child(route)
	for i in 4:
		var marker := Marker2D.new()
		route.add_child(marker)
		marker.global_position = MapManager.cell_to_world(MapManager.random_cell_near(start_cell, 8))
	return route

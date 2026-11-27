class_name Thief
extends Node2D

## The player: reads the keys and gives them to its components

const DIRECTIONS := {
	&"left": Vector2i.LEFT,
	&"right": Vector2i.RIGHT,
	&"up": Vector2i.UP,
	&"down": Vector2i.DOWN,
}

@onready var movement_component: MovementComponent = %MovementComponent
@onready var pickup_component: PickupComponent = %PickupComponent
@onready var smoke_component: SmokeComponent = %SmokeComponent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var current_cell: Vector2i:
	get: return movement_component.current_cell
var is_active: bool = false

var _start_position: Vector2
var _last_cell := Vector2i(-1, -1)

func _ready() -> void:
	_start_position = global_position
	animated_sprite_2d.pause()

	movement_component.movement_stopped.connect(func (): animated_sprite_2d.pause())
	movement_component.direction_changed.connect(func (dir: Vector2i):
		match dir:
			Vector2i.LEFT: animated_sprite_2d.play("left")
			Vector2i.RIGHT: animated_sprite_2d.play("right")
			Vector2i.UP: animated_sprite_2d.play("up")
			Vector2i.DOWN: animated_sprite_2d.play("down")
	)


func _physics_process(delta: float) -> void:
	if not is_active: return
	movement_component.ignores_walls = DebugSettings.walks_through_walls
	_leave_wall_if_stuck()
	_process_inputs()
	movement_component.update_movement(delta * DebugSettings.thief_speed)
	_check_cell()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return

	if event.is_action_pressed("smoke"):
		smoke_component.throw()

	# The last key pressed wins, even when another one is still held
	for action: StringName in DIRECTIONS:
		if event.is_action_pressed(action):
			movement_component.requested_direction = DIRECTIONS[action]


## A key held during the intro never sends a "pressed" event once the game starts
func _process_inputs() -> void:
	if movement_component.requested_direction != Vector2i.ZERO:
		return

	for action: StringName in DIRECTIONS:
		if Input.is_action_pressed(action):
			movement_component.requested_direction = DIRECTIONS[action]


func _check_cell() -> void:
	var cell := current_cell
	pickup_component.check_cell(cell)
	if cell != _last_cell:
		_last_cell = cell
		EventBus.thief_moved.emit(cell)


## Debug menu: "walk through walls" can be turned off while inside a wall
func _leave_wall_if_stuck() -> void:
	if not movement_component.ignores_walls and MapManager.is_wall_cell(current_cell):
		reset()


func teleport_to(cell: Vector2i) -> void:
	movement_component.stop()
	global_position = MapManager.cell_to_world(cell)


func reset() -> void:
	global_position = _start_position
	_last_cell = Vector2i(-1, -1)
	movement_component.stop()
	animated_sprite_2d.play("down")
	animated_sprite_2d.pause()


func play_caught() -> void:
	is_active = false
	AudioManager.stop_clip()
	AudioManager.play_one_shot("Caught")
	animated_sprite_2d.play("caught")
	await animated_sprite_2d.animation_finished
	await get_tree().create_timer(0.5).timeout

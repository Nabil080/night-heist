class_name DirectionIndicatorComponent
extends Polygon2D

## Debug view: an arrow pointing where the movement component wants to go

@export var _enabled := true:
	set(val): _enabled = val; visible = val
@export var _movement_component: MovementComponent
@export var _default_orientation := Vector2i.DOWN

var _offset := 0.0


func _ready() -> void:
	_offset = position.length()
	_movement_component.requested_direction_changed.connect(func (dir: Vector2i):
		position = Vector2(dir) * _offset
		rotation = Vector2(_default_orientation).angle_to(dir)
	)

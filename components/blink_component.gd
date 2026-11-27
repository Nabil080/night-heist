class_name BlinkComponent
extends Node

## Makes its parent blink. Every blink pauses when the level is frozen.

static var is_active := true

@export var interval := 0.3
@export_range(0.0, 1.0) var min_opacity := 0.0
@export var auto_start := true

var _target: CanvasItem
var _initial_opacity: float
var _timer: Timer
var _visible := true


func _ready() -> void:
	_target = get_parent() as CanvasItem
	assert(_target)
	_initial_opacity = _target.modulate.a

	_timer = Timer.new()
	_timer.wait_time = interval
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

	if auto_start:
		start()


func start() -> void:
	_timer.start()


func stop() -> void:
	_timer.stop()


func _on_timeout() -> void:
	# While frozen it still finishes the blink, so nothing stays hidden
	if is_active or not _visible:
		_visible = not _visible
		_target.modulate.a = _initial_opacity if _visible else min_opacity

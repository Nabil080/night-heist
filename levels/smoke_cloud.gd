class_name SmokeCloud
extends Node2D

## Stuns the guards that are in it, and hides the scent of the thief

@export var duration := 1.6
@export var scent_radius := 4

@onready var smoke_area: Area2D = $SmokeArea
@onready var particles: CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	particles.emitting = true
	smoke_area.area_entered.connect(func (area: Area2D): (area.owner as Guard).stun())

	var level := get_parent() as Level
	level.scent_trail.clear_around.call_deferred(MapManager.world_to_cell(level.thief.global_position), scent_radius)

	await get_tree().create_timer(duration, false).timeout
	queue_free()

class_name DifficultySettings
extends Resource

## Everything that gets harder from one room to the next.
## The ranges are the same as the sliders of the debug menu.

## In pixels per second
@export_range(10.0, 150.0, 1.0) var guard_speed := 44.0
## In cells
@export_range(0, 15) var vision_range := 4
## Seconds a guard still knows where the thief is after losing sight of him
@export_range(0.0, 10.0, 0.1) var chase_memory := 1.0
@export_range(0.0, 20.0, 0.1) var search_time := 3.0
## Seconds before a footprint disappears
@export_range(1.0, 30.0, 0.5) var scent_lifetime := 5.0
## In cells, 0 means the guards don't call each other
@export_range(0, 30) var alarm_radius := 0
@export_range(0.5, 15.0, 0.1) var stun_time := 5.0

class_name GlobalDebugSettings
extends Node

## The debug menu writes here and the game reads it

var is_invincible := false
var is_invisible := false
var walks_through_walls := false
var has_infinite_smoke := false
var teleport_on_click := false
var thief_speed := 1.0

var guards_frozen := false
var guards_blind := false
var guard_speed := 1.0

var skip_intro := false

var show_paths := false
var show_states := false
var show_grid := false
var show_flashlights := true
var show_footprints := true

var game_speed := 1.0:
	set(val): game_speed = val; Engine.time_scale = val
var mute_music := false:
	set(val): mute_music = val; AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), val)
var mute_effects := false:
	set(val): mute_effects = val; AudioServer.set_bus_mute(AudioServer.get_bus_index("SoundEffects"), val)

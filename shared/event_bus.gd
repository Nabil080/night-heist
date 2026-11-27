class_name GlobalEventBus
extends Node

## Signals any node can emit or listen to, so the game parts don't need each other

@warning_ignore_start("unused_signal")
signal points_scored(points: int)

signal thief_moved(cell: Vector2i)
signal thief_spotted(cell: Vector2i, spotted_by: Guard)
signal thief_caught
signal thief_escaped

signal loot_changed(loot_left: int)
signal all_loot_collected
signal smoke_collected
signal smoke_changed(count: int)

signal chase_started
signal chase_ended
signal chase_reset

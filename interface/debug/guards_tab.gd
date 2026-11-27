class_name DebugGuardsTab
extends DebugTab

const PATROLLER = preload("res://characters/guards/patroller.tscn")
const TRACKER = preload("res://characters/guards/tracker.tscn")
const WARDEN = preload("res://characters/guards/warden.tscn")

var guards: Array[Node]:
	get: return level.guards.get_children()


func _ready() -> void:
	super()
	_bind(%StunAll, func (): for guard: Guard in guards: guard.stun())
	_bind(%AllChase, func (): for guard: Guard in guards: guard.brain.change_to(&"Chase"))
	_bind(%AllSearch, func ():
		for guard: Guard in guards:
			guard.brain.change_to(&"Search", {"cell": level.thief.current_cell})
	)
	_bind(%AllDefault, func (): for guard: Guard in guards: guard.brain.start())
	_bind(%SpawnPatroller, func (): level.spawn_guard(PATROLLER))
	_bind(%SpawnTracker, func (): level.spawn_guard(TRACKER))
	_bind(%SpawnWarden, func (): level.spawn_guard(WARDEN))
	_bind(%RemoveLast, func ():
		if not guards.is_empty():
			(guards.back() as Guard).remove()
	)
	_bind(%RemoveAll, func (): for guard: Guard in guards: guard.remove())

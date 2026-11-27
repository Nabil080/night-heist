class_name DebugThiefTab
extends DebugTab

## Cheats for the thief: lives, smoke bombs, score


func _ready() -> void:
	super()
	_bind(%AddLife, func (): game.lives += 1)
	_bind(%AddSmoke, func (): level.thief.smoke_component.count += 1)
	_bind(%AddScore, func (): EventBus.points_scored.emit(1000))
	_bind(%ThrowSmoke, func (): level.thief.smoke_component.throw())
	_bind(%BackToStart, func (): level.thief.reset())

extends Node

## Plays the music clips one at a time and the sound effects on top of them

@onready var clips: Node = %Clips
@onready var one_shots: Node = %OneShots

var active_clip: AudioStreamPlayer


func _ready() -> void:
	for clip: AudioStreamPlayer in clips.get_children():
		clip.bus = "Music"
	for clip: AudioStreamPlayer in one_shots.get_children():
		clip.bus = "SoundEffects"


func play_clip(audio_name: String, from_position: float = 0.0, skip_restart: bool = true) -> void:
	if skip_restart and active_clip and active_clip.name == audio_name:
		return

	stop_clip()
	active_clip = clips.get_node(audio_name)
	active_clip.play(from_position)


func stop_clip() -> void:
	if not active_clip: return
	active_clip.stop()
	active_clip = null


func play_one_shot(audio_name: String, from_position: float = 0.0) -> void:
	var audio_stream: AudioStreamPlayer = one_shots.get_node(audio_name)

	var oneshot := audio_stream.duplicate()
	add_child(oneshot)
	oneshot.play(from_position)

	oneshot.finished.connect(oneshot.queue_free)

extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions
enum object_types {TOOL, NONTOOL}

const transition_time: float = 0.25
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false


signal level_instantiated(level_name: String)

func _ready():
	pass

func play_sfx(sfx: Object, direction: Directions):
	if direction == player_direction.CLOCKWISE:
		sfx.pitch_scale += 0.03
		sfx.play()
	else:
		sfx.pitch_scale -= 0.03
		sfx.play()

func restart_level_sfx_vfx(sfxs: Array):
	# PERFORM SOME CUTSCENES AFTER RESTARTING
	# SFX
	for sfx in sfxs:
		sfx.play()

func change_level(scene_path: String, levels_frame):
	# Remove current level
	for child in levels_frame.get_children():
		child.queue_free()

	# Load and add new level
	var new_level = load(scene_path).instantiate()
	levels_frame.add_child(new_level)
	notify_level_instantiated(scene_path) # Notify that a new level has been instantiated

func restart_level(levels_frame):
	# Remove and Re-open current level
	var current_level = levels_frame.get_child(0)

	if current_level:
		var level_scene = load(current_level.scene_file_path) 
		current_level.queue_free()
		var new_level = level_scene.instantiate()
		levels_frame.add_child(new_level)
		#notify_level_instantiated(current_level.scene_file_path) # Notify that the level has been restarted

func notify_level_instantiated(scene_path: String):
	var level_name := ""
	if "seed" in scene_path:
		level_name = "seed"
	elif "old_man" in scene_path or "oldman" in scene_path \
			or "level_2" in scene_path:
		level_name = "old man"
	elif "rock" in scene_path or "level_3" in scene_path:
		level_name = "rock"
	elif "dog" in scene_path or "level_4" in scene_path:
		level_name = "dog"
	else:
		level_name = scene_path
	emit_signal("level_instantiated", level_name)

extends Node2D

signal level_instantiated(level_name: String)
signal level_completed(level_name: String)

# LEVEL INTRO GUIDE:
#   1. Initialize Level Handler component in the level map and initialize as onready variable.
#   2. Add a tween_rotate and a tween_scale as tween type variables in the level map
#   3. In _onready(), call the map_initialize from level handler and pass, self, tween_rotate and tween_scale.

func map_initialize(this, tween_rotate, tween_scale):
	GlobalVariables.is_looping = true
	GlobalVariables.player_stopped = false

	# INITIALLY ROTATE TO 360 DEGREES
	this.rotation = deg_to_rad(360.0)

	# INITIALLY SET THE SCALE TO 0
	this.scale = Vector2(0.0, 0.0)

	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_rotate_finished").bind(tween_rotate))

	var rotation_tween = rotation - deg_to_rad(360.0)
	tween_rotate.tween_property(this, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_scale_finished").bind(tween_scale))
	tween_scale.tween_property(this, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

# NEXT LEVEL GUIDE:
#	1. If not done yet, initialize Level Handler component in the scene script and initialize as onready variable.
#	2. Add a tween_rotate and a tween_scale as tween type variables in the scene script.
# 	3. When next level is desired call the next_level func from the level handler and pass
#		self, the tween_rotate, the tween_scale and the next_level path.

# NEXT LEVEL
func next_level(this, tween_rotate, tween_scale, next_level_path):
	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_next_rotate_finished").bind(tween_rotate))

	var rotation_tween = this.rotation - deg_to_rad(-360.0)
	tween_rotate.tween_property(this, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_next_scale_finished").bind(tween_scale))
	tween_scale.tween_property(this, "scale", Vector2(0.0, 0.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(1.0).timeout

	# NEXT LEVEL
	change_level(next_level_path, this.get_parent())

func tween_rotate_finished(tween_created):
	print("Rotate Killed")
	tween_created.kill()

func tween_scale_finished(tween_created):
	print("Scale Killed")
	tween_created.kill()
	
func tween_next_rotate_finished(tween_created):
	print("Next Rotate Killed")
	tween_created.kill()

func tween_next_scale_finished(tween_created):
	print("Next Scale Killed")
	tween_created.kill()

func change_level(scene_path: String, levels_frame):
	# Remove current level
	for child in levels_frame.get_children():
		child.queue_free()

	# Load and add new level
	var new_level = load(scene_path).instantiate()
	levels_frame.add_child(new_level)
	notify_level_instantiated(scene_path) # Notify that a new level has been instantiated
	
func get_level_name_from_path(scene_path: String) -> String:
	if "seed" in scene_path or "level_1" in scene_path:
		return "level_1"
	elif "old_man" in scene_path or "oldman" in scene_path \
			or "level_2" in scene_path:
		return "level_2"
	elif "rock" in scene_path or "level_3" in scene_path:
		return "level_3"
	elif "dog" in scene_path or "level_4" in scene_path:
		return "level_4"
	else:
		return scene_path

func notify_level_instantiated(scene_path: String):
	var level_name = get_level_name_from_path(scene_path)
	print("Level Handler: Current level is ", level_name)
	emit_signal("level_instantiated", level_name)

func notify_level_completed(scene_path: String):
	var level_name = get_level_name_from_path(scene_path)
	print("Level Handler: Level completed - ", level_name)
	emit_signal("level_completed", level_name)

# Call this method from the level scripts when the level objective is met
func complete_current_level(levels_frame):
	var current_level = levels_frame.get_child(0)
	if current_level:
		notify_level_completed(current_level.scene_file_path)
	#put this "level_handler.complete_current_level(get_parent().get_parent())"

func restart_level(levels_frame):
	# Remove and Re-open current level
	var current_level = levels_frame.get_child(0)

	if current_level:
		var level_scene = load(current_level.scene_file_path) 
		current_level.queue_free()
		var new_level = level_scene.instantiate()
		levels_frame.add_child(new_level)
		#notify_level_instantiated(current_level.scene_file_path) # Notify that the level has been restarted

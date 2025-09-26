extends Node2D

signal level_instantiated(level_name: String)
signal level_completed(level_name: String)
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

var current_level_number: int = 0
var current_player: CharacterBody2D = null
# Make completed_levels static so it persists across scene changes
static var completed_levels: Array[int] = [] # Track completed levels
# Global level count - change this when adding more levels
const TOTAL_LEVEL_COUNT: int = 4
@onready var level_select_node = $level_select

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

	# Connect to player after map initialization
	call_deferred("connect_to_player", this)

# Para sa level select, nakaconnect sa player input 'yung long hand ng clock movement
func connect_to_player(level_scene):
	# Find the player in the current level
	var player = level_scene.get_node_or_null("PlayerScene")
	if player:
		current_player = player
		# Connect player signals to level_select
		if player.has_signal("player_finished_moving"):
			player.player_finished_moving.connect(level_select_node._on_player_moved)
		level_select_node.set_player_reference(player)

# NEXT LEVEL GUIDE:
#	1. If not done yet, initialize Level Handler component in the scene script and initialize as onready variable.
#	2. Add a tween_rotate and a tween_scale as tween type variables in the scene script.
# 	3. When next level is desired call the next_level func from the level handler and pass
#		self, the tween_rotate, the tween_scale and the next_level path.


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

# Call this method from level scripts in their _ready() function to identify the level
# Example: level_handler.set_current_level(1)
func set_current_level(level_number: int):
	current_level_number = level_number
	var level_name = "level_" + str(level_number)
	print("Level Handler: Current level set to ", level_name)
	emit_signal("level_instantiated", level_name)
	
	# Set hand position based on level (in ui/level_select.gd)
	match level_number:
		1:
			level_select_node.set_hand_to_clock_position(12) # 12 o'clock for level 1
		2:
			level_select_node.set_hand_to_clock_position(3)
		3:
			level_select_node.set_hand_to_clock_position(6)
		4:
			level_select_node.set_hand_to_clock_position(9)
		_:
			level_select_node.set_hand_to_clock_position(12) # 12 o'clock for other levels

# Call this method from the level scripts when the level objective is met
# Example: level_handler.complete_current_level(get_parent().get_parent())
func complete_current_level(levels_frame):
	if current_level_number > 0:
		var level_name = "level_" + str(current_level_number)
		emit_signal("level_completed", level_name)
		
		# Mark level as completed and print status
		_mark_level_completed_and_print_status()
		
		# PROCEED TO NEXT LEVEL IF AVAILABLE
		var next_level_number = current_level_number + 1
		if next_level_number <= TOTAL_LEVEL_COUNT:
			var level_scene = levels_frame.get_child(0) # Get current level scene
			
			# KILL THE CURRENT LEVEL WITH ANIMATION (TWEEN KILL)
			kill_current_level(level_scene)
			await get_tree().create_timer(1.0).timeout

			# SHOW TRANSITION CUTSCENE
			await show_level_transition_cutscene(next_level_number)

			# LOAD THE NEW LEVEL
			load_next_level(next_level_number, levels_frame)

# Helper function to mark level as completed and print status
func _mark_level_completed_and_print_status():
	# Add current level to completed levels FIRST
	if not completed_levels.has(current_level_number):
		completed_levels.append(current_level_number)
	
	# Print completed levels with checkmarks
	var completed_status = ""
	for i in range(1, TOTAL_LEVEL_COUNT + 1):
		if completed_levels.has(i):
			completed_status += "level " + str(i) + " ✓, "
		else:
			completed_status += "level " + str(i) + " ✗, "
	
	# Remove the last comma and space
	completed_status = completed_status.trim_suffix(", ")
	print("Level Handler: ", completed_status)

func show_level_transition_cutscene(next_level_number: int):
	# SHOW CLOCK CUTSCENE WITH LONG HAND ANIMATION
	level_select_node.show_level_complete_cutscene(next_level_number)
	
	# ANIMATE THE LONG HAND TO NEXT LEVEL POSITION
	var animation_tween = level_select_node.animate_hand_to_next_level(level_select_node.get_clock_position_for_level(next_level_number))
	if animation_tween:
		# WAIT FOR HAND ANIMATION TO COMPLETE
		await animation_tween.finished
	
	# KEEP CUTSCENE VISIBLE FOR A MOMENT
	await get_tree().create_timer(2.0).timeout
	
	# HIDE THE CUTSCENE
	level_select_node.hide_cutscene()

func load_next_level(next_level_number: int, levels_frame):
	var next_level_path = "res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn"
	change_level(next_level_path, levels_frame)
	ui_handler.set_default_time_indicator()

func restart_level(levels_frame):
	# Remove and Re-open current level
	var current_level = levels_frame.get_child(0)

	if current_level:
		var level_scene = load(current_level.scene_file_path) 
		current_level.queue_free()
		var new_level = level_scene.instantiate()
		levels_frame.add_child(new_level)

func kill_current_level(level_scene):
	# PHASE 1: KILL THE CURRENT LEVEL WITH ROTATION AND SCALE TWEENS
	var tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_next_rotate_finished").bind(tween_rotate))
	var rotation_tween = level_scene.rotation - deg_to_rad(-360.0)
	tween_rotate.tween_property(level_scene, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	var tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_next_scale_finished").bind(tween_scale))
	tween_scale.tween_property(level_scene, "scale", Vector2(0.0, 0.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)



extends Node2D

signal level_instantiated(level_name: String)
signal level_completed(level_name: String)
signal short_hand_state_changed(level_number: int, is_unlocked: bool)
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

var current_level_number: int = 0
var current_player: CharacterBody2D = null
var is_lobby: bool = false # Track if we're in the lobby scene
var is_replaying_completed_level: bool = false # Track if current level was already completed
# Make completed_levels static so it persists across scene changes
static var completed_levels: Array[int] = [] # Track completed levels
# Global level count - change this when adding more levels
const TOTAL_LEVEL_COUNT: int = 12
@onready var level_status_node = $level_status

# LEVEL INTRO GUIDE:
#   1. Initialize Level Handler component in the level map and initialize as onready variable.
#   2. Add a tween_rotate and a tween_scale as tween type variables in the level map
#   3. In _onready(), call the map_initialize from level handler and pass, self, tween_rotate and tween_scale.

func map_initialize(this, tween_rotate, tween_scale):
	
	GlobalVariables.is_looping = true
	GlobalVariables.player_stopped = false

	# INITIALLY ROTATE TO 360 DEGREES
	this.rotation = deg_to_rad(360.0)

	# INITIALLY SET THE SCALE TO VERY SMALL (not 0 to avoid determinant issues)
	this.scale = Vector2(0.01, 0.01)

	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_rotate_finished").bind(tween_rotate))

	var rotation_tween = rotation - deg_to_rad(360.0)
	tween_rotate.tween_property(this, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_scale_finished").bind(tween_scale))
	tween_scale.tween_property(this, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	# Connect level handler signals to level status
	if not short_hand_state_changed.is_connected(level_status_node._on_short_hand_state_changed):
		short_hand_state_changed.connect(level_status_node._on_short_hand_state_changed)

	# Connect to player after map initialization
	call_deferred("connect_to_player", this)

# Para sa level select, nakaconnect sa player input 'yung long hand ng clock movement
func connect_to_player(level_scene):
	# Find the player in the current level
	var player = level_scene.get_node_or_null("PlayerScene")
	if player:
		current_player = player
		# Connect player signals to level_status
		if player.has_signal("player_finished_moving"):
			player.player_finished_moving.connect(level_status_node._on_player_moved)
		level_status_node.set_player_reference(player)

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
	# Check if the scene file exists before trying to load it
	if not ResourceLoader.exists(scene_path):
		print("Level Handler: Scene file not found: ", scene_path)
		print("Level Handler: Returning to lobby instead")
		return_to_lobby(levels_frame)
		return
	
	# Remove current level
	for child in levels_frame.get_children():
		child.queue_free()

	# Load and add new level
	var new_level = load(scene_path).instantiate()
	levels_frame.add_child(new_level)

# Call this method from level scripts in the their _ready() function to identify the level
# Example: level_handler.set_current_level(1)
func set_current_level(level_number: int):
	current_level_number = level_number
	is_lobby = false # We're in a regular level, not lobby
	
	# Check if this level was already completed before
	is_replaying_completed_level = completed_levels.has(level_number)
	
	var level_name = "level_" + str(level_number)
	print("Level Handler: Current level set to ", level_name)
	if is_replaying_completed_level:
		print("Level Handler: This is a replay of an already completed level")
	
	emit_signal("level_instantiated", level_name)
	
	# Update long hand state for current level
	update_short_hand_state_for_level(level_number)
	
	# Start hint timers when entering a level
	if ui_handler and ui_handler.has_node("ui_logic/overlay/hint"):
		var hint = ui_handler.get_node("ui_logic/overlay/hint")
		hint.get_node("hint_dialog/hint_2/hint_2_timer").start()
	

# Call this method from level_lobby script in its _ready() function to identify it as lobby
# Example: level_handler.set_current_lobby()
func set_current_lobby():
	current_level_number = 0
	is_lobby = true
	print("Level Handler: Current scene set to lobby")
	emit_signal("level_instantiated", "lobby")
	
	# Resume hand following in lobby
	level_status_node.resume_following_player()
	
	# Update long hand state for level 1 (default lobby position)
	update_short_hand_state_for_level(1)

# Call this method from the level scripts when the level objective is met
# Example: level_handler.complete_current_level(get_parent().get_parent())
func complete_current_level(levels_frame):
	if current_level_number > 0:
		# KILL ANY EXISTING TWEENS FIRST - More comprehensive tween killing
		var current_level = levels_frame.get_child(0)
		if current_level:
			# Kill all tweens in the scene tree
			_kill_all_level_tweens(current_level)
		
		# Stop player movement immediately
		if current_player:
			GlobalVariables.player_stopped = true
			# Disable player input to prevent further movement
			current_player.set_physics_process(false)
			current_player.set_process_input(false)
		
		# Stop hand from following player and preserve position
		level_status_node.stop_following_player()
		
		# Force set hand position to current level's clock position
		match current_level_number:
			1:
				level_status_node.set_hand_to_clock_position(1) # 1 o'clock for level 1
			2:
				level_status_node.set_hand_to_clock_position(2) # 2 o'clock for level 2
			3:
				level_status_node.set_hand_to_clock_position(3) # 3 o'clock for level 3
			4:
				level_status_node.set_hand_to_clock_position(4) # 4 o'clock for level 4
			5:
				level_status_node.set_hand_to_clock_position(5) # 5 o'clock for level 5
			6:
				level_status_node.set_hand_to_clock_position(6) # 6 o'clock for level 6
			7:
				level_status_node.set_hand_to_clock_position(7) # 7 o'clock for level 7
			8:
				level_status_node.set_hand_to_clock_position(8) # 8 o'clock for level 8
			9:
				level_status_node.set_hand_to_clock_position(9) # 9 o'clock for level 9
			10:
				level_status_node.set_hand_to_clock_position(10) # 10 o'clock for level 10
			11:
				level_status_node.set_hand_to_clock_position(11) # 11 o'clock for level 11
			12:
				level_status_node.set_hand_to_clock_position(12) # 12 o'clock for level 12
			_:
				level_status_node.set_hand_to_clock_position(1) # 1 o'clock for other levels
		
		var level_name = "level_" + str(current_level_number)
		emit_signal("level_completed", level_name)
		
		# Mark level as completed and print status (only if not already completed)
		if not is_replaying_completed_level:
			_mark_level_completed_and_print_status()
		
		# KILL THE CURRENT LEVEL WITH ANIMATION (TWEEN KILL) - Wait for completion
		kill_current_level(current_level)
		await get_tree().create_timer(1.2).timeout  # Increased wait time to ensure tween completion

		# Check if this is a replay of an already completed level
		if is_replaying_completed_level:
			# Skip cutscene and go directly to lobby for replayed levels
			print("Level Handler: Skipping cutscene for replayed level, going directly to lobby")
			return_to_lobby(levels_frame)
		else:
			# Show story cutscene first, then clock animation, then next level
			# Calculate next level number for cutscene
			var next_level_number = current_level_number + 1
			if next_level_number > TOTAL_LEVEL_COUNT:
				next_level_number = 1 # Loop back to level 1
			
			# SHOW STORY CUTSCENE FIRST
			if ui_handler:
				ui_handler.show_level_cutscene(next_level_number, func(): _show_clock_then_load_level(next_level_number, levels_frame))

# New function to show clock animation then load next level
func _show_clock_then_load_level(next_level_number: int, levels_frame):
	# Show clock animation cutscene
	await show_level_transition_cutscene(next_level_number)
	
	# Load next level after clock animation
	_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)

func load_next_level(next_level_number: int, levels_frame):
	var next_level_path = "res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn"
	
	# Check if the level file exists before trying to load it
	if ResourceLoader.exists(next_level_path):
		# Show cutscene first before loading level
		if ui_handler:
			ui_handler.show_level_cutscene(next_level_number, func(): _continue_to_level(next_level_path, levels_frame))
	else:
		# Level doesn't exist yet, return to lobby instead
		print("Level Handler: Level ", next_level_number, " scene file not found, returning to lobby")
		return_to_lobby(levels_frame)

# New function to load level directly without cutscene (for lobby transitions)
func load_next_level_directly(next_level_number: int, levels_frame):
	var next_level_path = "res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn"
	
	# Check if the level file exists before trying to load it
	if ResourceLoader.exists(next_level_path):
		_continue_to_level(next_level_path, levels_frame)
	else:
		# Level doesn't exist yet, return to lobby instead
		print("Level Handler: Level ", next_level_number, " scene file not found, returning to lobby")
		return_to_lobby(levels_frame)

# Modified function to continue to level after cutscene
func _continue_to_level(level_path: String, levels_frame):
	change_level(level_path, levels_frame)
	ui_handler.set_default_time_indicator()
	
	# ENSURE UI IS VISIBLE WHEN ENTERING NEXT LEVEL
	ui_handler.visible = true

func return_to_lobby(levels_frame):
	var lobby_path = "res://Scenes/levels/level_lobby.tscn"
	change_level(lobby_path, levels_frame)
	ui_handler.set_default_time_indicator()
	
	# ENSURE UI IS VISIBLE WHEN RETURNING TO LOBBY
	ui_handler.visible = true
	
	# If we're returning from a replay, ensure hand can follow player again
	if is_replaying_completed_level:
		# Clear preserved hand rotation so lobby can sync properly to player
		level_status_node.preserved_hand_rotation = 0.0
		# Resume hand following for lobby
		level_status_node.resume_following_player()
	
	# RESTART FOREST AMBIENCE WHEN RETURNING TO LOBBY
	await get_tree().create_timer(0.1).timeout  # Small delay to ensure scene is loaded
	var lobby_scene = levels_frame.get_child(0)
	if lobby_scene and lobby_scene.has_node("SoundManager"):
		var sound_manager = lobby_scene.get_node("SoundManager")
		sound_manager.play_ambience_sfx("forest_sfx")


# Helper function to mark level as completed and print status
func _mark_level_completed_and_print_status():
	# Add current level to completed levels FIRST
	if not completed_levels.has(current_level_number):
		completed_levels.append(current_level_number)
	
	# Update long hand state for completed level
	update_short_hand_state_for_level(current_level_number)
	
	# Print completed levels with checkmarks
	print_completion_status()

# Public function to print completion status
func print_completion_status():
	var completed_status = ""
	for i in range(1, TOTAL_LEVEL_COUNT + 1):
		if completed_levels.has(i):
			completed_status += "level " + str(i) + " ✓, "
		else:
			completed_status += "level " + str(i) + " ✗, "
	
	# Remove the last comma and space
	completed_status = completed_status.trim_suffix(", ")
	print("Level Handler: ", completed_status)

# Centralized function to update long hand state and notify listeners
func update_short_hand_state_for_level(level_number: int):
	if level_number <= 0:
		return
		
	var is_unlocked = completed_levels.has(level_number)
	emit_signal("short_hand_state_changed", level_number, is_unlocked)

func show_level_transition_cutscene(next_level_number: int):
	
	# SHOW CLOCK CUTSCENE WITH LONG HAND ANIMATION
	level_status_node.show_level_complete_cutscene(next_level_number)
	
	# WAIT FOR LOCK STATE TO BE VISIBLE (show locked state first)
	await get_tree().create_timer(1.0).timeout
	
	# ANIMATE THE LONG HAND TO NEXT LEVEL POSITION DURING CUTSCENE
	var next_level_clock_position = level_status_node.get_clock_position_for_level(next_level_number)
	var animation_tween = level_status_node.animate_hand_to_next_level(next_level_clock_position)
	if animation_tween:
		# WAIT FOR HAND ANIMATION TO COMPLETE
		await animation_tween.finished
	
	# KEEP CUTSCENE VISIBLE FOR A MOMENT AFTER ANIMATION
	await get_tree().create_timer(1.0).timeout
	
	# HIDE THE CUTSCENE
	level_status_node.hide_cutscene()

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
	# First, kill any existing tweens on the level scene
	if level_scene.has_method("get_meta") and level_scene.has_meta("tweens"):
		var scene_tweens = level_scene.get_meta("tweens")
		for tween in scene_tweens:
			if tween and tween.is_valid():
				tween.kill()
	
	var tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_next_rotate_finished").bind(tween_rotate))
	var rotation_tween = level_scene.rotation - deg_to_rad(-360.0)
	tween_rotate.tween_property(level_scene, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	var tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_next_scale_finished").bind(tween_scale))
	# Scale to very small instead of 0 to avoid determinant issues
	tween_scale.tween_property(level_scene, "scale", Vector2(0.01, 0.01), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)


# Helper function to kill all tweens in a level scene
func _kill_all_level_tweens(level_scene: Node):
	# Kill tweens in the level scene and all its children recursively
	_recursive_kill_tweens(level_scene)
	
	# Also kill any global tweens
	var tweens = get_tree().get_nodes_in_group("tweens")
	for tween in tweens:
		if tween and tween.is_valid():
			tween.kill()

# Recursive function to kill tweens in all nodes
func _recursive_kill_tweens(node: Node):
	# Check if node has tweens and kill them
	for child in node.get_children():
		# Kill tweens on this child
		if child.has_method("create_tween"):
			# Try to access any tween properties that might exist
			var properties = child.get_property_list()
			for property in properties:
				if property.name.contains("tween"):
					var tween_obj = child.get(property.name)
					if tween_obj and typeof(tween_obj) == TYPE_OBJECT and tween_obj.has_method("kill"):
						if tween_obj.is_valid():
							tween_obj.kill()
		
		# Recursively check children
		_recursive_kill_tweens(child)

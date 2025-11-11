extends Node2D

# SIGNALS
signal level_instantiated(level_name: String)
signal level_completed(level_name: String)
signal short_hand_state_changed(level_number: int, is_unlocked: bool)
signal map_scale_tween_finished() 
signal hint_level_changed(level_number: int) # NEW SIGNAL FOR HINT SYSTEM

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
var player = null # Will be set when level_scene is available

var current_level_number: int = 0
var current_player: CharacterBody2D = null
var is_lobby: bool = false # Track if we're in the lobby scene
var is_replaying_completed_level: bool = false # Track if current level was already completed
# Make completed_levels static so it persists across scene changes
static var completed_levels: Array[int] = [] # Track completed levels
# Global level count - change this when adding more levels
const TOTAL_LEVEL_COUNT: int = 12
@onready var level_status_node = $level_status

# References for hint system
var hint_component = null
# NEW: store the lobby clock position just before entering a level (used for replay return animation)
var pre_entry_clock_pos: int = 12
# NEW: persist the exact last entrance index used to enter a level (survives scene change)
static var last_entered_level: int = 0
# NEW: track whether the last-instantiated level was a replay
static var last_play_was_replay: bool = false

# NEW: node being initialized (used to hide/show during map tweens)
var initializing_map_node: Node = null

# LEVEL INTRO GUIDE:
#   1. Initialize Level Handler component in the level map and initialize as onready variable.
#   2. Add a tween_rotate and a tween_scale as tween type variables in the level map
#   3. In _onready(), call the map_initialize from level handler and pass, self, tween_rotate and tween_scale.

func map_initialize(this, tween_rotate, tween_scale):
	# TODO: MAP INITIALIZATION
	
	# Ensure the map/lobby node is hidden until its intro tweens finish
	initializing_map_node = this
	if initializing_map_node and "visible" in initializing_map_node:
		initializing_map_node.visible = false

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

	map_scale_tween_finished.emit()

	# Connect level handler signals to level status
	if not short_hand_state_changed.is_connected(level_status_node._on_short_hand_state_changed):
		short_hand_state_changed.connect(level_status_node._on_short_hand_state_changed)

	# Connect to player after map initialization
	call_deferred("connect_to_player", this)

# PARA SA LEVEL SELECT, NAKACONNECT SA PLAYER INPUT 'YUNG LONG HAND NG CLOCK MOVEMENT
func connect_to_player(level_scene):
	player = level_scene.get_node_or_null("PlayerScene")
	if player:
		current_player = player
		# CONNECT PLAYER SIGNALS TO LEVEL_STATUS
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
	# Restore visibility of the node being initialized (if any)
	if initializing_map_node and "visible" in initializing_map_node:
		initializing_map_node.visible = true
	initializing_map_node = null
	
func tween_next_rotate_finished(tween_created):
	print("Next Rotate Killed")
	tween_created.kill()

func tween_next_scale_finished(tween_created):
	print("Next Scale Killed")
	tween_created.kill()

func change_level(scene_path: String, levels_frame):
	if not ResourceLoader.exists(scene_path):
		print("Level Handler: Scene file not found: ", scene_path)
		print("Level Handler: Returning to lobby instead")
		return_to_lobby(levels_frame)
		return
	
	# Collect current children and hide them (keep container visible so UI doesn't flash)
	var old_children: Array = []
	if levels_frame:
		for child in levels_frame.get_children():
			old_children.append(child)
			if "visible" in child:
				child.visible = false
	
	# LOAD AND ADD NEW LEVEL (start hidden)
	var new_level = load(scene_path).instantiate()
	if new_level:
		if "visible" in new_level:
			new_level.visible = false
		levels_frame.add_child(new_level)
	
	# Allow one frame + small delay so the new scene can run _ready() and initialize resources
	await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	
	# Show the new level now that it's initialized
	if new_level and "visible" in new_level:
		new_level.visible = true
	
	# Free the old children after the new level is visible (prevents flash)
	for child in old_children:
		if child and child.is_inside_tree():
			child.queue_free()

# CALL THIS METHOD FROM LEVEL SCRIPTS IN THE THEIR _READY() FUNCTION TO IDENTIFY THE LEVEL
# EXAMPLE: LEVEL_HANDLER.SET_CURRENT_LEVEL(1)
func set_current_level(level_number: int):
	current_level_number = level_number
	is_lobby = false # We're in a regular level, not lobby
	
	# Check if this level was already completed before
	is_replaying_completed_level = completed_levels.has(level_number)
	# Track globally whether this instantiation is a replay
	last_play_was_replay = is_replaying_completed_level
	
	var level_name = "level_" + str(level_number)
	print("Level Handler: Current level set to ", level_name)
	if is_replaying_completed_level:
		print("Level Handler: This is a replay of an already completed level")
	
	emit_signal("level_instantiated", level_name)
	emit_signal("hint_level_changed", level_number) # Notify hint system of current level

# CALL THIS METHOD FROM LEVEL_LOBBY SCRIPT IN ITS _READY() FUNCTION TO IDENTIFY IT AS LOBBY
# EXAMPLE: LEVEL_HANDLER.SET_CURRENT_LOBBY()
func set_current_lobby():
	current_level_number = 0
	is_lobby = true
	print("Level Handler: Current scene set to lobby")
	emit_signal("level_instantiated", "lobby")
	
	level_status_node.resume_following_player()
	emit_signal("hint_level_changed", 0) # Notify hint system of lobby

# CALL THIS METHOD FROM THE LEVEL SCRIPTS WHEN THE LEVEL OBJECTIVE IS MET
# EXAMPLE: LEVEL_HANDLER.COMPLETE_CURRENT_LEVEL(GET_PARENT().GET_PARENT())
func complete_current_level(levels_frame):
	if current_level_number > 0:
		# KILL ANY EXISTING TWEENS FIRST - More comprehensive tween killing
		var current_level = levels_frame.get_child(0)
		if current_level:
			# KILL ALL TWEENS IN THE SCENE TREE
			_kill_all_level_tweens(current_level)
		
		# STOP PLAYER MOVEMENT IMMEDIATELY
		if current_player:
			GlobalVariables.player_stopped = true
			# DISABLE PLAYER INPUT TO PREVENT FURTHER MOVEMENT
			current_player.set_physics_process(false)
			current_player.set_process_input(false)
		
		# STOP HINT TIMERS IF THEY EXIST
		if ui_handler and ui_handler.has_node("ui_logic/overlay/hint"):
			var hint = ui_handler.get_node("ui_logic/overlay/hint")
			var hint_2_timer = hint.get_node_or_null("hint_box/hint_box_empty/hint_2/hint_2_timer")
			var solution_timer = hint.get_node_or_null("hint_box/hint_box_empty/solution/solution_timer")
			
			if hint_2_timer:
				hint_2_timer.stop()
			if solution_timer:
				solution_timer.stop()
		
		# STOP HAND FROM FOLLOWING PLAYER AND PRESERVE POSITION
		level_status_node.stop_following_player()
		
		# FORCE SET HAND POSITION TO CURRENT LEVEL'S CLOCK POSITION
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
		
		# MARK LEVEL AS COMPLETED AND PRINT STATUS (ONLY IF NOT ALREADY COMPLETED)
		if not is_replaying_completed_level:
			_mark_level_completed_and_print_status()
		
		# KILL THE CURRENT LEVEL WITH ANIMATION (TWEEN KILL) - Wait for completion
		kill_current_level(current_level)
		await get_tree().create_timer(1.2).timeout  # Increased wait time to ensure tween completion

		# MARK NEXT LEVEL NUMBER (wrap)
		var next_level_number = current_level_number + 1
		if next_level_number > TOTAL_LEVEL_COUNT:
			next_level_number = 1

		# If this is a replay of an already completed level, return immediately to lobby
		if is_replaying_completed_level:
			print("Level Handler: Replay completed level - returning to lobby")
			await return_to_lobby(levels_frame)
			
			# Wait briefly so the lobby scene has time to run its _ready and initialize nodes
			await get_tree().create_timer(0.12).timeout
			
			# After lobby was instantiated, play a replay-return animation from the replayed level
			var lobby_scene = levels_frame.get_child(0)
			if lobby_scene and lobby_scene.has_method("start_replay_return_animation"):
				# Use persisted last_entered_level if available, otherwise fallback to the current level
				var target_pos = last_entered_level if last_entered_level > 0 else current_level_number
				lobby_scene.start_replay_return_animation(current_level_number, target_pos)
			return
		else:
			# For first-time completion, return to lobby first then let lobby drive cutscene -> clock -> next level
			await return_to_lobby(levels_frame)

			# After lobby was instantiated, request the lobby scene to start its cutscene + clock animation then enter the next level
			var lobby_scene = levels_frame.get_child(0)
			if lobby_scene and lobby_scene.has_method("start_cutscene_then_enter_next_level"):
				lobby_scene.start_cutscene_then_enter_next_level(next_level_number)
			else:
				# Fallback: run the cutscene and directly continue to next level from here
				if ui_handler:
					ui_handler.show_level_cutscene(next_level_number, func(): _continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame))
				else:
					_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)
# NEW HELPER: show the clock animation/cutscene then return to lobby
func _show_clock_then_return_lobby(_cutscene_level_number: int, levels_frame):
	# Play the same transition cutscene used elsewhere, wait for it, then return to lobby
	await show_level_transition_cutscene(_cutscene_level_number)
	return_to_lobby(levels_frame)

# NEW FUNCTION TO SHOW CLOCK ANIMATION THEN LOAD NEXT LEVEL
func _show_clock_then_load_level(next_level_number: int, levels_frame):
	# Show clock animation cutscene
	await show_level_transition_cutscene(next_level_number)
	
	# Load next level after clock animation
	_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)

# func load_next_level(next_level_number: int, levels_frame):
# 	var next_level_path = "res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn"
	
# 	# Check if the level file exists before trying to load it
# 	if ResourceLoader.exists(next_level_path):
# 		# Show cutscene first before loading level
# 		if ui_handler:
# 			ui_handler.show_level_cutscene(next_level_number, func(): _continue_to_level(next_level_path, levels_frame))
# 	else:
# 		# Level doesn't exist yet, return to lobby instead
# 		print("Level Handler: Level ", next_level_number, " scene file not found, returning to lobby")
# 		return_to_lobby(levels_frame)

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
	# Reset player moves and map state before loading new level
	GlobalVariables.player_moves = 0
	
	change_level(level_path, levels_frame)
	ui_handler.set_default_time_indicator()
	
	# ENSURE UI IS VISIBLE WHEN ENTERING NEXT LEVEL
	ui_handler.visible = true

func return_to_lobby(levels_frame):
	# Reset player moves when returning to lobby
	GlobalVariables.player_moves = 0
	
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
	await get_tree().create_timer(0.1).timeout  
	var lobby_scene = levels_frame.get_child(0)
	if lobby_scene and lobby_scene.has_node("SoundManager"):
		var sound_manager = lobby_scene.get_node("SoundManager")
		sound_manager.play_ambience_sfx("forest_sfx")


# HELPER FUNCTION TO MARK LEVEL AS COMPLETED AND PRINT STATUS
func _mark_level_completed_and_print_status():
	# Add current level to completed levels FIRST
	if not completed_levels.has(current_level_number):
		completed_levels.append(current_level_number)

	print_completion_status()

# PUBLIC FUNCTION TO PRINT COMPLETION STATUS
func print_completion_status():
	var completed_status = ""
	for i in range(1, TOTAL_LEVEL_COUNT + 1):
		if completed_levels.has(i):
			completed_status += "level " + str(i) + " ✓, "
		else:
			completed_status += "level " + str(i) + " ✗, "
	
	completed_status = completed_status.trim_suffix(", ")
	print("Level Handler: ", completed_status)

# CENTRALIZED FUNCTION TO UPDATE LONG HAND STATE AND NOTIFY LISTENERS
func update_short_hand_state_for_level(_level_number: int):
	# Remove lock/unlock logic, do nothing
	pass

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
	# REMOVE AND RE-OPEN CURRENT LEVEL
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


# HELPER FUNCTION TO KILL ALL TWEENS IN A LEVEL SCENE
func _kill_all_level_tweens(level_scene: Node):
	_recursive_kill_tweens(level_scene)
	
	var tweens = get_tree().get_nodes_in_group("tweens")
	for tween in tweens:
		if tween and tween.is_valid():
			tween.kill()

# RECURSIVE FUNCTION TO KILL TWEENS IN ALL NODES
func _recursive_kill_tweens(node: Node):
	for child in node.get_children():
		if child.has_method("create_tween"):
			var properties = child.get_property_list()
			for property in properties:
				if property.name.contains("tween"):
					var tween_obj = child.get(property.name)
					if tween_obj and typeof(tween_obj) == TYPE_OBJECT and tween_obj.has_method("kill"):
						if tween_obj.is_valid():
							tween_obj.kill()
		
		_recursive_kill_tweens(child)

func _ready() -> void:
	if not ui_handler:
		ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")
	
	if ui_handler and ui_handler.has_node("ui_logic/overlay/hint"):
		hint_component = ui_handler.get_node("ui_logic/overlay/hint")
	
	if not level_instantiated.is_connected(_on_level_instantiated):
		level_instantiated.connect(_on_level_instantiated)
	
	call_deferred("_check_and_start_hint_timers")

func _on_level_instantiated(_level_name: String) -> void:
	_check_and_start_hint_timers()

# HELPER FUNCTION TO CHECK AND START HINT TIMERS
func _check_and_start_hint_timers() -> void:
	if not is_lobby and current_level_number > 0 and hint_component:
		
		var hint_2_timer = hint_component.get_node_or_null("hint_box/hint_box_empty/hint_2/hint_2_timer")
		if hint_2_timer and hint_2_timer.time_left <= 0:
			
			var level_key = "level_" + str(current_level_number)
			var current_difficulty = "hard"  
			
			if hint_component.hint_progress.has(level_key):
				current_difficulty = hint_component.hint_progress[level_key]
			
			if current_difficulty == "hard":
				print("Level Handler: Starting hint timer for level ", current_level_number)
				hint_2_timer.start()
				
				var timer_label = hint_2_timer.get_node_or_null("timer_label")
				if timer_label:
					timer_label.text = hint_component.format_time(hint_2_timer.time_left)
					timer_label.visible = false
					timer_label.modulate.a = 0
	
	elif is_lobby and hint_component:
		var hint_2_timer = hint_component.get_node_or_null("hint_box/hint_box_empty/hint_2/hint_2_timer")
		var solution_timer = hint_component.get_node_or_null("hint_box/hint_box_empty/solution/solution_timer")
		
		if hint_2_timer:
			hint_2_timer.stop()
		if solution_timer:
			solution_timer.stop()

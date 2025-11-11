extends Node2D

@export var source_tilemap: TileMapLayer

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager

# UI HANDLER REFERENCE
var ui_handler = null

# LOBBY ACTIVE FLAG
var lobby_active: bool = true

var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0, 0)

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

@onready var enter_1: object_class = $enter_1 
@onready var enter_2: object_class = $enter_2
@onready var enter_3: object_class = $enter_3
@onready var enter_4: object_class = $enter_4
@onready var enter_5: object_class = $enter_5
@onready var enter_6: object_class = $enter_6
@onready var enter_7: object_class = $enter_7
@onready var enter_8: object_class = $enter_8
@onready var enter_9: object_class = $enter_9
@onready var enter_10: object_class = $enter_10
@onready var enter_11: object_class = $enter_11
@onready var enter_12: object_class = $enter_12

# Add clock_area variable for lobby
var clock_area: int = 12

func _ready():
	call_deferred("initialize_text_labels")
	# GET UI HANDLER REFERENCE
	ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")
	
	# HIDE GAME UI ELEMENTS WHEN IN LOBBY
	ui_handler.hide_game_ui_elements()

	await get_tree().process_frame
	lobby_active = true
	
	
	if level_handler:
		level_handler.set_current_lobby()
	else:
		print("Error: level_handler not found")
		return
		
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# Show/hide clock_base only, remove level_clock reference
	level_handler.level_status_node.get_node("clock_base").visible = true
	
	level_handler.visible = false

	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	call_deferred("update_completed_levels_visual")
	
	# CONNECT TO LEVEL COMPLETED SIGNAL
	level_handler.level_completed.connect(_on_level_completed)
	
	# POSITION PLAYER BASED ON LAST COMPLETED LEVEL
	call_deferred("position_player_based_on_progress")
	sound_manager.play_ambience_sfx("forest_sfx")
	
	GlobalVariables.is_looping = false
	# Reset player moves to 0 so map stays at default frame 0 in lobby
	GlobalVariables.player_moves = 0

# INITIALIZE TEXT LABELS FOR ALL ENTRANCE OBJECTS
func initialize_text_labels():
	var entrances = [enter_1, enter_2, enter_3, enter_4, enter_5, enter_6, enter_7, enter_8, enter_9, enter_10, enter_11, enter_12]
	for entrance in entrances:
		# Check if entrance exists before trying to access it
		if entrance and entrance.has_node("hover_text"):
			var hover_label = entrance.get_node("hover_text")
			hover_label.visible = false
			
		if entrance and entrance.has_node("interact_text"):
			var interact_label = entrance.get_node("interact_text")
			interact_label.visible = false

func objects_initialize():
	# Dynamically add all entrance objects to the objects array
	for i in range(1, 13):  # For levels 1-12
		var entrance_var_name = "enter_" + str(i)
		var entrance = get(entrance_var_name)
		if entrance:
			objects.append(entrance)

func _process(_delta: float) -> void:
	if not lobby_active:
		return
	level_handler.visible = true

# ADD THIS METHOD TO HANDLE LEVEL TRANSITIONS FROM LOBBY
func enter_level(level_number: int):
	# RECORD THE LOBBY HAND POSITION BEFORE LEAVING (for replay return)
	if level_handler:
		# persist the exact entrance index so replay return can position the player back here
		level_handler.last_entered_level = level_number
	
	# DISABLE ALL LOBBY FUNCTIONALITY IMMEDIATELY
	disable_lobby_functionality()
	print("Entering level ", level_number)
	
	# CHECK IF THE LEVEL SCENE FILE EXISTS BEFORE ATTEMPTING TO ENTER
	var level_path = "res://Scenes/levels/level_" + str(level_number) + "_scene.tscn"
	if not ResourceLoader.exists(level_path):
		print("Level ", level_number, " is not ready yet!")
		# RE-ENABLE LOBBY IF LEVEL DOESN'T EXIST
		enable_lobby_functionality()
		return  
	
	# STOP FOREST AMBIENCE WHEN LEAVING LOBBY
	sound_manager.stop_ambience_sfx("forest_sfx")
	# GET THE LEVELS_FRAME FROM THE GAME SCENE STRUCTURE
	var levels_frame = get_parent() 

	# KILL THE CURRENT LOBBY MAP WITH ANIMATION
	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# SHOW STORY CUTSCENE FIRST, THEN CLOCK ANIMATION, THEN LEVEL
	# TODO: Dito yung show clock anim then level
	if ui_handler:
		ui_handler.show_level_cutscene(level_number, func(): _show_clock_animation_then_level(level_number, levels_frame))

# SHOW CLOCK ANIMATION THEN PROCEED TO LEVEL
func _show_clock_animation_then_level(level_number: int, levels_frame):
	print("Showing clock animation for level ", level_number)
	# Show clock_base only, remove level_clock reference
	level_handler.level_status_node.get_node("clock_base").visible = true

	# --- NEW: ensure hand starts from last completed level (or 12 if none)
	var highest_completed_level = 0
	for lvl in level_handler.completed_levels:
		if lvl > highest_completed_level:
			highest_completed_level = lvl
	var start_hand_pos = highest_completed_level if highest_completed_level > 0 else 12
	# Force the clock hands to the last completed position and preserve rotations for the cutscene
	level_handler.level_status_node.set_hand_to_clock_position(start_hand_pos)

	# Show entry cutscene WITHOUT forcing hands to 12 so animation starts from preserved/last-completed position
	level_handler.level_status_node.show_level_entry_cutscene()
	await get_tree().create_timer(1.0).timeout
	
	# ANIMATE HAND FROM CURRENT (preserved) POSITION TO TARGET LEVEL POSITION
	var target_clock_position = level_handler.level_status_node.get_clock_position_for_level(level_number)
	var animation_tween = level_handler.level_status_node.animate_hand_to_next_level(target_clock_position)
	if animation_tween:
		await animation_tween.finished
	
	await get_tree().create_timer(1.0).timeout
	level_handler.level_status_node.hide_cutscene()
	
	# SHOW GAME UI ELEMENTS WHEN ENTERING ACTUAL LEVEL
	ui_handler.show_game_ui_elements()
	
	level_handler.load_next_level_directly(level_number, levels_frame)


# UPDATE VISUAL INDICATORS FOR COMPLETED LEVELS
func update_completed_levels_visual():
	print("Updating completed levels visual...")
	print("Completed levels: ", level_handler.completed_levels)
	
	# CHECK EACH LEVEL AND UPDATE SPRITE COLOR BASED ON COMPLETION STATUS
	for level_num in range(1, 13):  # LEVELS 1-12
		var is_completed = level_handler.completed_levels.has(level_num)
		print("Level ", level_num, " - Completed: ", is_completed)
		
		# Dynamically access the entrance node using get()
		var entrance_var_name = "enter_" + str(level_num)
		var entrance = get(entrance_var_name)
		
		# Update the entrance if it exists
		if entrance:
			entrance.set_level_completion_visual(is_completed)

# COMPLETELY DISABLE A COMPLETED ENTRANCE OBJECT
func disable_entrance_completely(entrance_obj):
	if not entrance_obj:
		return
		
	print("Completely disabling entrance: ", entrance_obj.object_name)
	entrance_obj.set_process(false)
	entrance_obj.set_physics_process(false)
	entrance_obj.set_process_input(false)
	entrance_obj.set_process_unhandled_input(false)
	entrance_obj.set_process_unhandled_key_input(false)
	
	if entrance_obj.has_node("CollisionShape2D"):
		entrance_obj.get_node("CollisionShape2D").disabled = true
	if entrance_obj.has_node("hover_text"):
		entrance_obj.get_node("hover_text").visible = false
	if entrance_obj.has_node("interact_text"):
		entrance_obj.get_node("interact_text").visible = false
	if entrance_obj.has_method("set") and "is_enterable" in entrance_obj:
		entrance_obj.is_enterable = false

func _on_level_completed(level_name: String):
	print("Level completed: ", level_name)
	call_deferred("update_completed_levels_visual")

# POSITION PLAYER BASED ON COMPLETED LEVELS PROGRESS
func position_player_based_on_progress():
	if not player:
		return

	# If we came back from a replayed play, place player at the exact entrance they used
	if level_handler and level_handler.last_play_was_replay and level_handler.last_entered_level > 0:
		var replay_pos = level_handler.last_entered_level
		# Place player and sync clock hand
		player.rotation = deg_to_rad(replay_pos * 30)
		if level_handler and level_handler.level_status_node:
			level_handler.level_status_node.set_hand_to_clock_position(replay_pos)
		# clear replay trackers so normal logic resumes afterwards
		level_handler.last_play_was_replay = false
		level_handler.last_entered_level = 0
		return
		
	# GET THE HIGHEST COMPLETED LEVEL TO DETERMINE PLAYER POSITION
	var highest_completed_level = 0
	for level_num in level_handler.completed_levels:
		if level_num > highest_completed_level:
			highest_completed_level = level_num
	
	# POSITION PLAYER AT THE NEXT LEVEL'S CLOCK POSITION
	var target_rotation = 0.0
	
	if highest_completed_level == 0:
		# No levels completed yet -> player at 12 o'clock target (360 deg -> 12)
		target_rotation = deg_to_rad(360.0) # treat 12 o'clock as full circle
		# Set clock hand start to 12
		level_handler.level_status_node.set_hand_to_clock_position(12)
	else:
		# If there is at least one completed level, start the hand at that completed level position
		# NEXT LEVEL FOR PLAYER IS highest_completed_level + 1 (but player placement uses next level)
		var next_level = highest_completed_level + 1
		if next_level > 12:
			next_level = 1
		target_rotation = deg_to_rad(next_level * 30)
		# Start clock hand at the latest completed level position
		level_handler.level_status_node.set_hand_to_clock_position(highest_completed_level)
	
	# SET PLAYER ROTATION DIRECTLY
	player.rotation = target_rotation
	
	# SET THE LONG HAND TO MATCH PLAYER'S INITIAL POSITION
	#call_deferred("sync_short_hand_to_player")

# CONNECT PLAYER MOVEMENT TO LONG HAND IN LOBBY
#func connect_player_to_short_hand():
	#if player and player.has_signal("player_finished_moving"):
		## CONNECT PLAYER MOVEMENT TO UPDATE LONG HAND
		#if not player.player_finished_moving.is_connected(_on_player_moved_in_lobby):
			#player.player_finished_moving.connect(_on_player_moved_in_lobby)
		
# HANDLE PLAYER MOVEMENT IN LOBBY TO UPDATE LONG HAND
#func _on_player_moved_in_lobby():
	#if not lobby_active:
		#return
		#
	#if player and level_handler.level_status_node:
		## IN LOBBY, MAKE LONG HAND FOLLOW PLAYER DIRECTLY
		##level_handler.level_status_node.short_hand_rotation.rotation = player.rotation
		#
		## UPDATE THE BASE_CLOCK_POSITION TO MATCH CURRENT POSITION
		#var current_degrees = rad_to_deg(player.rotation)
		#var current_clock_pos = level_handler.level_status_node.get_clock_position_from_rotation(current_degrees)
		#level_handler.level_status_node.base_clock_position = current_clock_pos
	#level_handler.level_status_node.update_lock_state()

#func sync_short_hand_to_player():
	#if not lobby_active:
		#return
		#
	#if level_handler.level_status_node.preserved_hand_rotation == 0.0:
		#level_handler.level_status_node.short_hand_rotation.rotation = player.rotation
	#else:
		#level_handler.level_status_node.short_hand_rotation.rotation = level_handler.level_status_node.preserved_hand_rotation
	#
	#var current_degrees = rad_to_deg(level_handler.level_status_node.short_hand_rotation.rotation)
	#var current_clock_pos = level_handler.level_status_node.get_clock_position_from_rotation(current_degrees)
	#level_handler.level_status_node.base_clock_position = current_clock_pos
	#level_handler.level_status_node.update_lock_state()
	#
	#level_handler.level_status_node.resume_following_player()

# DISABLE ALL LOBBY FUNCTIONALITY
func disable_lobby_functionality():
	lobby_active = false
	
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		player.set_process_input(false)
	for obj in objects:
		if obj:
			obj.set_process(false)
			obj.set_physics_process(false)
			obj.set_process_input(false)
			if obj.has_node("hover_text"):
				obj.get_node("hover_text").visible = false
			if obj.has_node("interact_text"):
				obj.get_node("interact_text").visible = false
	if tween_rotate and tween_rotate.is_valid():
		tween_rotate.kill()
	if tween_scale and tween_scale.is_valid():
		tween_scale.kill()
	if level_handler:
		level_handler.set_process(false)
	if sound_manager:
		sound_manager.set_process(false)

# RE-ENABLE LOBBY FUNCTIONALITY (FOR WHEN RETURNING FROM LEVEL)
func enable_lobby_functionality():
	lobby_active = true
	
	# HIDE GAME UI ELEMENTS WHEN RETURNING TO LOBBY
	ui_handler.hide_game_ui_elements()
	
	if player:
		player.set_process(true)
		player.set_physics_process(true)
		player.set_process_input(true)
	
	for obj in objects:
		if obj:
			var level_number = get_level_number_from_entrance(obj)
			var is_completed = level_handler.completed_levels.has(level_number)
			
			if not is_completed:
				obj.set_process(true)
				obj.set_physics_process(true)
				obj.set_process_input(true)
	
	if level_handler:
		level_handler.set_process(true)
	
	if sound_manager:
		sound_manager.set_process(true)

# ADD THIS METHOD TO BE CALLED AFTER RETURNING TO LOBBY
func start_cutscene_then_enter_next_level(next_level_number: int):
	# Disable lobby so player cannot interact while lobby plays cutscene/clock animation
	disable_lobby_functionality()
	
	# Stop lobby ambience immediately
	if sound_manager:
		sound_manager.stop_ambience_sfx("forest_sfx")
	
	var levels_frame = get_parent()
	
	# Reuse existing UI cutscene -> clock animation -> load level flow
	if ui_handler:
		ui_handler.show_level_cutscene(next_level_number, func(): _show_clock_animation_then_level(next_level_number, levels_frame))
	else:
		_show_clock_animation_then_level(next_level_number, levels_frame)

# NEW: Play animation when returning from a replayed level.
# Animates clock hands from 'from_level' -> 'to_level', then re-enables lobby and places player at to_level.
func start_replay_return_animation(from_level: int, to_level: int):
	# disable interactions while playing
	disable_lobby_functionality()
	
	# ensure clock base visible and set start hand position
	if level_handler and level_handler.level_status_node:
		# Force the hands to start at the replayed level (preserve for cutscene)
		level_handler.level_status_node.set_hand_to_clock_position(from_level)
		level_handler.level_status_node.show_level_entry_cutscene()
	
	# animate to the recorded lobby position
	var animation_tween = level_handler.level_status_node.animate_hand_to_next_level(to_level)
	if animation_tween:
		await animation_tween.finished
	
	# small delay then hide cutscene
	await get_tree().create_timer(0.3).timeout
	level_handler.level_status_node.hide_cutscene()
	
	# Place player at the resulting clock position (fetch PlayerScene now to ensure it's ready)
	var lobby_player = get_node_or_null("PlayerScene")
	if lobby_player:
		lobby_player.rotation = deg_to_rad(to_level * 30)
	else:
		# fallback: update onready player var if available
		if player:
			player.rotation = deg_to_rad(to_level * 30)
	
	# Clear replay tracker (safety)
	if level_handler:
		level_handler.last_play_was_replay = false
		level_handler.last_entered_level = 0
	
	# re-enable lobby and UI
	enable_lobby_functionality()
	if sound_manager:
		sound_manager.play_ambience_sfx("forest_sfx")

# HELPER FUNCTION TO GET LEVEL NUMBER FROM ENTRANCE OBJECT NAME
func get_level_number_from_entrance(entrance_obj) -> int:
	if not entrance_obj or not entrance_obj.has_method("get") or not "object_name" in entrance_obj:
		return 0
		
	var obj_name = entrance_obj.object_name
	# EXTRACT NUMBER FROM "ENTER_X" FORMAT
	if obj_name.begins_with("enter_"):
		var num_str = obj_name.substr(6) 
		return int(num_str)
	return 0

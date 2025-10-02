extends Node2D

@export var source_tilemap: TileMapLayer

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager

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


func _ready():
	# Wait for level_handler to be ready before calling set_current_lobby
	await get_tree().process_frame
	
	# Ensure lobby starts as active
	lobby_active = true
	
	if level_handler:
		level_handler.set_current_lobby()
	else:
		print("Error: level_handler not found")
		return
		
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# Make clock visible in lobby for level selection but hide the clock texture
	level_handler.level_status_node.visible = true
	level_handler.level_status_node.get_node("level_clock").visible = false
	
	level_handler.visible = false

	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
	# Initialize text labels for all entrance objects
	call_deferred("initialize_text_labels")
	
	# UPDATE COMPLETED LEVELS VISUAL - moved to after text is always accessible
	call_deferred("update_completed_levels_visual")
	
	# CONNECT TO LEVEL COMPLETED SIGNAL
	level_handler.level_completed.connect(_on_level_completed)
	
	# POSITION PLAYER BASED ON LAST COMPLETED LEVEL
	call_deferred("position_player_based_on_progress")
	
	# PLAY FOREST AMBIENCE IN LOBBY
	sound_manager.play_ambience_sfx("forest_sfx")

# Initialize text labels for all entrance objects
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
	# Only append entrance objects that actually exist
	if enter_1:
		objects.append(enter_1)
	if enter_2:
		objects.append(enter_2)
	if enter_3:
		objects.append(enter_3)
	if enter_4:
		objects.append(enter_4)
	if enter_5:
		objects.append(enter_5)
	if enter_6:
		objects.append(enter_6)
	if enter_7:
		objects.append(enter_7)
	if enter_8:
		objects.append(enter_8)
	if enter_9:
		objects.append(enter_9)
	if enter_10:
		objects.append(enter_10)
	if enter_11:
		objects.append(enter_11)
	if enter_12:
		objects.append(enter_12)

func _process(_delta: float) -> void:
	if not lobby_active:
		return
	level_handler.visible = true

# Add this method to handle level transitions from lobby
func enter_level(level_number: int):
	# DISABLE ALL LOBBY FUNCTIONALITY IMMEDIATELY
	disable_lobby_functionality()
	
	print("Entering level ", level_number)
	
	# Check if the level scene file exists before attempting to enter
	var level_path = "res://Scenes/levels/level_" + str(level_number) + "_scene.tscn"
	if not ResourceLoader.exists(level_path):
		print("Level ", level_number, " is not ready yet!")
		# Re-enable lobby if level doesn't exist
		enable_lobby_functionality()
		return  # Exit early if level doesn't exist
	
	# STOP FOREST AMBIENCE WHEN LEAVING LOBBY
	sound_manager.stop_ambience_sfx("forest_sfx")
	# Get the levels_frame from the game scene structure
	var levels_frame = get_parent()  # This should be the levels_frame

	# Kill the current lobby map with animation
	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# Show story cutscene first, then clock animation, then level
	var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
	if ui_handler:
		ui_handler.show_level_cutscene(level_number, func(): _show_clock_animation_then_level(level_number, levels_frame))

# Show clock animation then proceed to level
func _show_clock_animation_then_level(level_number: int, levels_frame):
	print("Showing clock animation for level ", level_number)
	
	# Show clock animation cutscene
	level_handler.level_status_node.get_node("level_clock").visible = true
	level_handler.level_status_node.show_level_1_entry_cutscene()
	
	# Wait for the initial display
	await get_tree().create_timer(1.0).timeout
	
	# Animate hand from 12 o'clock to target level position
	var target_clock_position = level_handler.level_status_node.get_clock_position_for_level(level_number)
	var animation_tween = level_handler.level_status_node.animate_hand_to_next_level(target_clock_position)
	if animation_tween:
		await animation_tween.finished
	
	# Keep cutscene visible for a moment after animation
	await get_tree().create_timer(1.0).timeout
	
	# Hide the cutscene
	level_handler.level_status_node.hide_cutscene()
	
	# Now proceed to level
	level_handler.load_next_level_directly(level_number, levels_frame)


# Update visual indicators for completed levels
func update_completed_levels_visual():
	print("Updating completed levels visual...")
	print("Completed levels: ", level_handler.completed_levels)
	
	# Check each level and update sprite color based on completion status
	for level_num in range(1, 13):  # Levels 1-12
		var is_completed = level_handler.completed_levels.has(level_num)
		print("Level ", level_num, " - Completed: ", is_completed)
		
		match level_num:
			1:
				if enter_1:
					enter_1.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_1)
			2:
				if enter_2:
					enter_2.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_2)
			3:
				if enter_3:
					enter_3.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_3)
			4:
				if enter_4:
					enter_4.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_4)
			5:
				if enter_5:
					enter_5.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_5)
			6:
				if enter_6:
					enter_6.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_6)
			7:
				if enter_7:
					enter_7.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_7)
			8:
				if enter_8:
					enter_8.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_8)
			9:
				if enter_9:
					enter_9.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_9)
			10:
				if enter_10:
					enter_10.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_10)
			11:
				if enter_11:
					enter_11.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_11)
			12:
				if enter_12:
					enter_12.set_level_completion_visual(is_completed)
					if is_completed:
						disable_entrance_completely(enter_12)

# Completely disable a completed entrance object
func disable_entrance_completely(entrance_obj):
	if not entrance_obj:
		return
		
	print("Completely disabling entrance: ", entrance_obj.object_name)
	
	# Disable all processing
	entrance_obj.set_process(false)
	entrance_obj.set_physics_process(false)
	entrance_obj.set_process_input(false)
	entrance_obj.set_process_unhandled_input(false)
	entrance_obj.set_process_unhandled_key_input(false)
	
	# Disable collision detection
	if entrance_obj.has_node("CollisionShape2D"):
		entrance_obj.get_node("CollisionShape2D").disabled = true
	
	# Hide all text labels permanently
	if entrance_obj.has_node("hover_text"):
		entrance_obj.get_node("hover_text").visible = false
	if entrance_obj.has_node("interact_text"):
		entrance_obj.get_node("interact_text").visible = false
	
	# Mark as not enterable if the property exists
	if entrance_obj.has_method("set") and "is_enterable" in entrance_obj:
		entrance_obj.is_enterable = false
	
	# Remove from area handler detection
	if area_handler and area_handler.has_method("remove_object_from_detection"):
		area_handler.remove_object_from_detection(entrance_obj)


# Called when a level is completed
func _on_level_completed(level_name: String):
	print("Level completed: ", level_name)
	# Update visual will happen when we return to lobby
	call_deferred("update_completed_levels_visual")

# Position player based on completed levels progress
func position_player_based_on_progress():
	if not player:
		return
		
	# Get the highest completed level to determine player position
	var highest_completed_level = 0
	for level_num in level_handler.completed_levels:
		if level_num > highest_completed_level:
			highest_completed_level = level_num
	
	# Position player at the next level's clock position
	var target_rotation = 0.0
	match highest_completed_level:
		0:
			# No levels completed, stay at default position (12 o'clock area)
			target_rotation = deg_to_rad(0) # 0 degrees
		1:
			# Level 1 completed, position at level 2 clock position (2 o'clock)
			target_rotation = deg_to_rad(60) # 2 o'clock = 60 degrees
		2:
			# Level 2 completed, position at level 3 clock position (3 o'clock)
			target_rotation = deg_to_rad(90) # 3 o'clock = 90 degrees
		3:
			# Level 3 completed, position at level 4 clock position (4 o'clock)
			target_rotation = deg_to_rad(120) # 4 o'clock = 120 degrees
		4:
			# Level 4 completed, position at level 5 clock position (5 o'clock)
			target_rotation = deg_to_rad(150) # 5 o'clock = 150 degrees
		5:
			# Level 5 completed, position at level 6 clock position (6 o'clock)
			target_rotation = deg_to_rad(180) # 6 o'clock = 180 degrees
		6:
			# Level 6 completed, position at level 7 clock position (7 o'clock)
			target_rotation = deg_to_rad(210) # 7 o'clock = 210 degrees
		7:
			# Level 7 completed, position at level 8 clock position (8 o'clock)
			target_rotation = deg_to_rad(240) # 8 o'clock = 240 degrees
		8:
			# Level 8 completed, position at level 9 clock position (9 o'clock)
			target_rotation = deg_to_rad(270) # 9 o'clock = 270 degrees
		9:
			# Level 9 completed, position at level 10 clock position (10 o'clock)
			target_rotation = deg_to_rad(300) # 10 o'clock = 300 degrees
		10:
			# Level 10 completed, position at level 11 clock position (11 o'clock)
			target_rotation = deg_to_rad(330) # 11 o'clock = 330 degrees
		11:
			# Level 11 completed, position at level 12 clock position (12 o'clock)
			target_rotation = deg_to_rad(0) # 12 o'clock = 0 degrees
		12:
			# All levels completed, position back at level 1 clock position (1 o'clock)
			target_rotation = deg_to_rad(30) # 1 o'clock = 30 degrees
		_:
			target_rotation = deg_to_rad(0) # Default fallback
	
	# Set player rotation directly
	player.rotation = target_rotation
	
	# Set the long hand to match player's initial position
	call_deferred("sync_short_hand_to_player")

# Connect player movement to long hand in lobby
func connect_player_to_short_hand():
	if player and player.has_signal("player_finished_moving"):
		# Connect player movement to update long hand
		if not player.player_finished_moving.is_connected(_on_player_moved_in_lobby):
			player.player_finished_moving.connect(_on_player_moved_in_lobby)
		
# Handle player movement in lobby to update long hand
func _on_player_moved_in_lobby():
	if not lobby_active:
		return
		
	if player and level_handler.level_status_node:
		# In lobby, make long hand follow player directly
		level_handler.level_status_node.short_hand_rotation.rotation = player.rotation
		
		# Update the base_clock_position to match current position
		var current_degrees = rad_to_deg(player.rotation)
		var current_clock_pos = level_handler.level_status_node.get_clock_position_from_rotation(current_degrees)
		level_handler.level_status_node.base_clock_position = current_clock_pos
		level_handler.level_status_node.update_lock_state()

func sync_short_hand_to_player():
	if not lobby_active:
		return
		
	# Check if this is coming from a replay (preserved rotation will be 0.0)
	if level_handler.level_status_node.preserved_hand_rotation == 0.0:
		# Coming from replay or first time - sync to player position
		level_handler.level_status_node.short_hand_rotation.rotation = player.rotation
		
	else:
		# Coming from cutscene - use preserved rotation
		level_handler.level_status_node.short_hand_rotation.rotation = level_handler.level_status_node.preserved_hand_rotation
	
	# Update the base_clock_position to match current position for consistency
	var current_degrees = rad_to_deg(level_handler.level_status_node.short_hand_rotation.rotation)
	var current_clock_pos = level_handler.level_status_node.get_clock_position_from_rotation(current_degrees)
	level_handler.level_status_node.base_clock_position = current_clock_pos
	level_handler.level_status_node.update_lock_state()
	
	# Always ensure hand following is enabled in lobby
	level_handler.level_status_node.resume_following_player()

# Disable all lobby functionality
func disable_lobby_functionality():
	lobby_active = false
	
	# Disable player input and movement
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		player.set_process_input(false)
	
	# Disable area handler
	if area_handler:
		area_handler.set_process(false)
		area_handler.set_physics_process(false)
	
	# Disable all entrance objects
	for obj in objects:
		if obj:
			obj.set_process(false)
			obj.set_physics_process(false)
			obj.set_process_input(false)
			# Hide text labels
			if obj.has_node("hover_text"):
				obj.get_node("hover_text").visible = false
			if obj.has_node("interact_text"):
				obj.get_node("interact_text").visible = false
	
	# Stop all tweens
	if tween_rotate and tween_rotate.is_valid():
		tween_rotate.kill()
	if tween_scale and tween_scale.is_valid():
		tween_scale.kill()
	
	# Disable level handler updates
	if level_handler:
		level_handler.set_process(false)
	
	# Disable sound manager
	if sound_manager:
		sound_manager.set_process(false)

# Re-enable lobby functionality (for when returning from level)
func enable_lobby_functionality():
	lobby_active = true
	
	# Re-enable player
	if player:
		player.set_process(true)
		player.set_physics_process(true)
		player.set_process_input(true)
	
	# Re-enable area handler
	if area_handler:
		area_handler.set_process(true)
		area_handler.set_physics_process(true)
	
	# Re-enable only non-completed entrance objects
	for obj in objects:
		if obj:
			# Check if this level is completed
			var level_number = get_level_number_from_entrance(obj)
			var is_completed = level_handler.completed_levels.has(level_number)
			
			if not is_completed:
				obj.set_process(true)
				obj.set_physics_process(true)
				obj.set_process_input(true)
			# If completed, keep it disabled
	
	# Re-enable level handler
	if level_handler:
		level_handler.set_process(true)
	
	# Re-enable sound manager
	if sound_manager:
		sound_manager.set_process(true)

# Helper function to get level number from entrance object name
func get_level_number_from_entrance(entrance_obj) -> int:
	if not entrance_obj or not entrance_obj.has_method("get") or not "object_name" in entrance_obj:
		return 0
		
	var obj_name = entrance_obj.object_name
	# Extract number from "enter_X" format
	if obj_name.begins_with("enter_"):
		var num_str = obj_name.substr(6) # Remove "enter_" prefix
		return int(num_str)
	return 0



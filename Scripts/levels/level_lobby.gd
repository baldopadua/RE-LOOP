extends Node2D

@export var source_tilemap: TileMapLayer

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager


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
	level_handler.set_current_lobby()
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
	level_handler.visible = true

# Add this method to handle level transitions from lobby
func enter_level(level_number: int):
	print("Entering level ", level_number)
	
	# Check if the level scene file exists before attempting to enter
	var level_path = "res://Scenes/levels/level_" + str(level_number) + "_scene.tscn"
	if not ResourceLoader.exists(level_path):
		print("Level ", level_number, " is not ready yet!")
		return  # Exit early if level doesn't exist
	
	# STOP FOREST AMBIENCE WHEN LEAVING LOBBY
	sound_manager.stop_ambience_sfx("forest_sfx")
	# Get the levels_frame from the game scene structure
	var levels_frame = get_parent()  # This should be the levels_frame

	# Kill the current lobby map with animation
	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# Special handling for level 1 - show cutscene first
	if level_number == 1:
		await show_level_1_entry_cutscene()
	
	
	# Use level_handler's load_next_level method
	level_handler.load_next_level(level_number, levels_frame)

# Show cutscene when entering level 1 from lobby
func show_level_1_entry_cutscene():
	print("Showing Level 1 entry cutscene")
	level_handler.level_status_node.get_node("level_clock").visible = true
	# Show the cutscene
	level_handler.level_status_node.show_level_1_entry_cutscene()
	
	# Wait for the initial display
	await get_tree().create_timer(1.0).timeout
	
	# Animate hand from 12 o'clock to 1 o'clock
	var animation_tween = level_handler.level_status_node.animate_hand_from_12_to_1()
	if animation_tween:
		await animation_tween.finished
	
	# Keep cutscene visible for a moment after animation
	await get_tree().create_timer(1.0).timeout
	
	# Hide the cutscene
	level_handler.level_status_node.hide_cutscene()

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
			2:
				if enter_2:
					enter_2.set_level_completion_visual(is_completed)
			3:
				if enter_3:
					enter_3.set_level_completion_visual(is_completed)
			4:
				if enter_4:
					enter_4.set_level_completion_visual(is_completed)
			5:
				if enter_5:
					enter_5.set_level_completion_visual(is_completed)
			6:
				if enter_6:
					enter_6.set_level_completion_visual(is_completed)
			7:
				if enter_7:
					enter_7.set_level_completion_visual(is_completed)
			8:
				if enter_8:
					enter_8.set_level_completion_visual(is_completed)
			9:
				if enter_9:
					enter_9.set_level_completion_visual(is_completed)
			10:
				if enter_10:
					enter_10.set_level_completion_visual(is_completed)
			11:
				if enter_11:
					enter_11.set_level_completion_visual(is_completed)
			12:
				if enter_12:
					enter_12.set_level_completion_visual(is_completed)
			

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
	if player and level_handler.level_status_node:
		# In lobby, make long hand follow player directly
		level_handler.level_status_node.short_hand_rotation.rotation = player.rotation
		
		# Update the base_clock_position to match current position
		var current_degrees = rad_to_deg(player.rotation)
		var current_clock_pos = level_handler.level_status_node.get_clock_position_from_rotation(current_degrees)
		level_handler.level_status_node.base_clock_position = current_clock_pos
		level_handler.level_status_node.update_lock_state()
		
		

func sync_short_hand_to_player():
	if player and level_handler.level_status_node:
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

extends Node2D

@onready var long_hand_rotation = $long_hand_rotation
@onready var long_hand_clock = $long_hand_rotation/long_hand_clock
var current_player: CharacterBody2D = null
var base_clock_position: int = 12 # Default base position
var should_follow_player: bool = true # Flag to control hand following

# Static variable to preserve hand position between cutscenes
static var preserved_hand_rotation: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initially hide the level_select cutscene
	visible = false

# Signal handler for long hand state changes from level handler
func _on_long_hand_state_changed(level_number: int, is_unlocked: bool):
	# Only update if the state change is for the current clock position
	var level_for_current_position = get_level_for_clock_position(base_clock_position)
	if level_number == level_for_current_position:
		if is_unlocked:
			long_hand_clock.play("unlock")
		else:
			long_hand_clock.play("lock")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_player_reference(player: CharacterBody2D):
	current_player = player

func _on_player_moved():
	if current_player and long_hand_rotation:
		update_hand_rotation()

func get_rotation_for_clock(clock: int) -> float:
	match clock:
		12:
			return 0.0 # 12 o'clock, 0 degrees
		1:
			return deg_to_rad(30) # 1 o'clock, 30 degrees
		2:
			return deg_to_rad(60) # 2 o'clock, 60 degrees
		3:
			return deg_to_rad(90) # 3 o'clock, 90 degrees
		4:
			return deg_to_rad(120) # 4 o'clock, 120 degrees
		5:
			return deg_to_rad(150) # 5 o'clock, 150 degrees
		6:
			return deg_to_rad(180) # 6 o'clock, 180 degrees
		7:
			return deg_to_rad(210) # 7 o'clock, 210 degrees
		8:
			return deg_to_rad(240) # 8 o'clock, 240 degrees
		9:
			return deg_to_rad(270) # 9 o'clock, 270 degrees
		10:
			return deg_to_rad(300) # 10 o'clock, 300 degrees
		11:
			return deg_to_rad(330) # 11 o'clock, 330 degrees
		_:
			return 0.0

func set_hand_to_clock_position(clock_position: int):
	base_clock_position = clock_position
	var target_rotation = get_rotation_for_clock(clock_position)
	
	# Set hand directly to position without animation for level transitions
	long_hand_rotation.rotation = target_rotation
	
	# Preserve this position for cutscene use
	preserved_hand_rotation = target_rotation
	print("DEBUG: Hand force set to clock position ", clock_position, " at ", rad_to_deg(target_rotation), " degrees")
	print("DEBUG: Position preserved for cutscene: ", rad_to_deg(preserved_hand_rotation), " degrees")
	
	# Update lock/unlock state based on current level completion
	update_lock_state()

func update_hand_rotation():
	if not current_player:
		return
	
	var level_handler = get_parent()
	if not level_handler:
		return
	
	# Don't follow player if flag is disabled
	if not should_follow_player:
		return
	
	# In lobby: Follow player directly (override preserved position behavior)
	if level_handler.is_lobby:
		# In lobby, make hand follow player rotation directly
		var target_rotation = current_player.rotation
		
		# Apply rotation smoothly
		var tween = create_tween()
		tween.tween_property(long_hand_rotation, "rotation", target_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		
		# Update base clock position based on player position
		var current_degrees = rad_to_deg(target_rotation)
		base_clock_position = get_clock_position_from_rotation(current_degrees)
	
	else:
		# In regular levels: use base rotation + player rotation as before
		var player_rotation = current_player.rotation
		var base_rotation = get_rotation_for_clock(base_clock_position)
		var target_hand_rotation = base_rotation + player_rotation
		
		# Get current hand rotation
		var current_hand_rotation = long_hand_rotation.rotation
		
		# Calculate the shortest path to target rotation
		var rotation_diff = target_hand_rotation - current_hand_rotation
		
		# Normalize to shortest path (-PI to PI)
		while rotation_diff > PI:
			rotation_diff -= 2 * PI
		while rotation_diff < -PI:
			rotation_diff += 2 * PI
		
		# Apply the shortest rotation path
		var final_rotation = current_hand_rotation + rotation_diff
		
		# Apply rotation smoothly without doing full spins
		var tween = create_tween()
		tween.tween_property(long_hand_rotation, "rotation", final_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
	
	# Update lock state after hand movement
	call_deferred("update_lock_state")

# Stop hand from following player (called when level is completed)
func stop_following_player():
	should_follow_player = false
	# Preserve current hand position for cutscene
	preserved_hand_rotation = long_hand_rotation.rotation
	

# Resume hand following player (called in lobby)
func resume_following_player():
	should_follow_player = true
	

func show_level_complete_cutscene(_next_level_number: int):
	
	
	# Stop hand from following player during cutscene
	should_follow_player = false
	
	# MAKE CUTSCENE VISIBLE - DO NOT RESET HAND POSITION
	visible = true
	
	# HIDE ALL GAMEPLAY ELEMENTS DURING CUTSCENE
	hide_gameplay_elements()
	
	# FORCE SHOW LOCK STATE FIRST
	if long_hand_clock:
		long_hand_clock.play("lock")
		
func hide_cutscene():
	visible = false
	
	# Restore gameplay elements when cutscene is hidden
	show_gameplay_elements()

func hide_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE
	var level_scene = get_parent().get_parent().get_parent()
	if level_scene:
		# HIDE ALL LEVEL CHILDREN EXCEPT ESSENTIAL ONES
		for child in level_scene.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = false

func show_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE
	var level_scene = get_parent().get_parent().get_parent()
	if level_scene:
		# RESTORE VISIBILITY OF ALL LEVEL CHILDREN
		for child in level_scene.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = true

func get_clock_position_for_level(level_number: int) -> int:
	match level_number:
		1:
			return 12 # 12 o'clock for level 1
		2:
			return 3 # 3 o'clock for level 2
		3:
			return 6 # 6 o'clock for level 3
		4:
			return 9 # 9 o'clock for level 4
		_:
			return 12 # 12 o'clock for other levels

func animate_hand_to_next_level(next_clock_position: int) -> Tween:
	# Use the preserved hand position as starting point (from level completion)
	var current_rotation = preserved_hand_rotation if preserved_hand_rotation != 0.0 else long_hand_rotation.rotation
	var target_rotation = get_rotation_for_clock(next_clock_position)
	
	# Set hand to preserved position first
	long_hand_rotation.rotation = current_rotation
	
	
	# SHOW UNLOCK ANIMATION FIRST BEFORE SLIDING
	if long_hand_clock:
		long_hand_clock.play("unlock")
		print("DEBUG: Playing unlock animation before slide")
	
	# Create a sequence tween that waits first, then slides
	var sequence_tween = create_tween()
	
	# Use tween_callback with a timer instead of tween_delay
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)
	
	# Calculate rotation difference
	var rotation_diff = target_rotation - current_rotation
	
	# Normalize the difference to find the shortest path first
	while rotation_diff > PI:
		rotation_diff -= 2 * PI
	while rotation_diff < -PI:
		rotation_diff += 2 * PI
	
	# If the shortest path is counter-clockwise, make it clockwise instead
	if rotation_diff < 0:
		rotation_diff += 2 * PI
	
	# Apply the clockwise rotation path
	var final_rotation = current_rotation + rotation_diff
	
	print("DEBUG: Sliding clockwise by: ", rad_to_deg(rotation_diff), " degrees")
	print("DEBUG: Final rotation will be: ", rad_to_deg(final_rotation), " degrees")
	
	# CREATE SMOOTH CUTSCENE ANIMATION - ALWAYS CLOCKWISE
	sequence_tween.tween_property(long_hand_rotation, "rotation", final_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)
	
	# FORCE SET BASE POSITION AND EXACT ROTATION AFTER ANIMATION
	sequence_tween.finished.connect(func(): 
		base_clock_position = next_clock_position
		long_hand_rotation.rotation = get_rotation_for_clock(next_clock_position)
		preserved_hand_rotation = long_hand_rotation.rotation # Save the position
		update_lock_state() # Update lock state after animation
	
	)
	
	return sequence_tween

func update_lock_state():
	if not long_hand_clock:
		return
	
	var level_handler = get_parent()
	if not level_handler:
		return
	
	# Get the level number based on CURRENT hand rotation, not base position
	var current_hand_degrees = rad_to_deg(long_hand_rotation.rotation)
	var current_clock_position = get_clock_position_from_rotation(current_hand_degrees)
	var level_for_current_rotation = get_level_for_clock_position(current_clock_position)
	
	# Check if the level at the CURRENT hand position is completed
	if level_for_current_rotation > 0 and level_handler.completed_levels.has(level_for_current_rotation):
		long_hand_clock.play("unlock")
	else:
		long_hand_clock.play("lock")

# New function to determine clock position from rotation degrees (based on your exact mapping)
func get_clock_position_from_rotation(degrees: float) -> int:
	# Round the degrees to match player's rounding
	var rounded_degrees = round(degrees)
	
	# Normalize degrees to 0-360 range
	var normalized_degrees = fmod(rounded_degrees + 360.0, 360.0)
	
	# Map degrees directly to clock positions based on your requirements:
	# 0° = 12 o'clock, 90° = 3 o'clock, 180° = 6 o'clock, 270° = 9 o'clock
	if normalized_degrees >= 315.0 or normalized_degrees < 45.0:
		return 12 # 0° ± 45° = 12 o'clock
	elif normalized_degrees >= 45.0 and normalized_degrees < 135.0:
		return 3 # 90° ± 45° = 3 o'clock
	elif normalized_degrees >= 135.0 and normalized_degrees < 225.0:
		return 6 # 180° ± 45° = 6 o'clock
	elif normalized_degrees >= 225.0 and normalized_degrees < 315.0:
		return 9 # 270° ± 45° = 9 o'clock
	else:
		return 12 # Default fallback

func get_level_for_clock_position(clock_position: int) -> int:
	match clock_position:
		12:
			return 1 # Level 1 at 12 o'clock
		3:
			return 2 # Level 2 at 3 o'clock
		6:
			return 3 # Level 3 at 6 o'clock
		9:
			return 4 # Level 4 at 9 o'clock
		_:
			return 0 # Unknown level

func _on_level_completed(_level_name: String):
	# Update lock state when any level is completed
	update_lock_state()

func _on_level_instantiated(_level_name: String):
	# Update lock state when entering a new level
	call_deferred("update_lock_state")
	# Update lock state when any level is completed
	update_lock_state()









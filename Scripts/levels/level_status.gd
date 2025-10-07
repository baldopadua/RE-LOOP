extends Node2D

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

@onready var short_hand_rotation = $short_hand_rotation
@onready var short_hand_clock = $short_hand_rotation/short_hand_clock
@onready var long_hand_rotation = $long_hand_rotation
@onready var long_hand_clock = $long_hand_rotation/long_hand_clock
var current_player: CharacterBody2D = null
var base_clock_position: int = 12 
var should_follow_player: bool = true 

# Static variable to preserve hand position between cutscenes
static var preserved_hand_rotation: float = 0.0
static var preserved_long_hand_rotation: float = 0.0

func _ready() -> void:
	visible = false

# Signal handler for long hand state changes from level handler
func _on_short_hand_state_changed(level_number: int, is_unlocked: bool):
	# Only update if the state change is for the current clock position
	var level_for_current_position = get_level_for_clock_position(base_clock_position)
	if level_number == level_for_current_position:
		if is_unlocked:
			short_hand_clock.play("unlock")
			long_hand_clock.play("unlock")
		else:
			short_hand_clock.play("lock")
			long_hand_clock.play("lock")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_player_reference(player: CharacterBody2D):
	current_player = player

func _on_player_moved():
	if current_player and short_hand_rotation:
		update_hand_rotation()

func get_rotation_for_clock(clock: int) -> float:
	# Handle 12 o'clock as special case (0 degrees)
	if clock == 12:
		return 0.0
	# Calculate rotation: each hour = 30 degrees
	return deg_to_rad(clock * 30.0)

func set_hand_to_clock_position(clock_position: int):
	base_clock_position = clock_position
	var target_rotation = get_rotation_for_clock(clock_position)
	
	# Set both hands directly to position without animation for level transitions
	short_hand_rotation.rotation = target_rotation
	long_hand_rotation.rotation = target_rotation
	
	# Preserve positions for cutscene use
	preserved_hand_rotation = target_rotation
	preserved_long_hand_rotation = target_rotation
	print("DEBUG: Both hands force set to clock position ", clock_position, " at ", rad_to_deg(target_rotation), " degrees")
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
		# In lobby, make both hands follow player rotation directly
		var target_rotation = current_player.rotation
		
		# Apply rotation smoothly to both hands
		var tween = create_tween()
		tween.parallel().tween_property(short_hand_rotation, "rotation", target_rotation, 0.15)
		tween.parallel().tween_property(long_hand_rotation, "rotation", target_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		
		# Update base clock position based on player position
		var current_degrees = rad_to_deg(target_rotation)
		base_clock_position = get_clock_position_from_rotation(current_degrees)
	
	else:
		# In regular levels: use base rotation + player rotation for both hands
		var player_rotation = current_player.rotation
		var base_rotation = get_rotation_for_clock(base_clock_position)
		var target_hand_rotation = base_rotation + player_rotation
		
		# Get current hand rotations
		var current_short_rotation = short_hand_rotation.rotation
		var current_long_rotation = long_hand_rotation.rotation
		
		# Calculate the shortest path to target rotation for both hands
		var short_rotation_diff = target_hand_rotation - current_short_rotation
		var long_rotation_diff = target_hand_rotation - current_long_rotation
		
		# Normalize to shortest path (-PI to PI) for both hands
		while short_rotation_diff > PI:
			short_rotation_diff -= 2 * PI
		while short_rotation_diff < -PI:
			short_rotation_diff += 2 * PI
			
		while long_rotation_diff > PI:
			long_rotation_diff -= 2 * PI
		while long_rotation_diff < -PI:
			long_rotation_diff += 2 * PI
		
		# Apply the shortest rotation path to both hands
		var final_short_rotation = current_short_rotation + short_rotation_diff
		var final_long_rotation = current_long_rotation + long_rotation_diff
		
		# Apply rotation smoothly to both hands
		var tween = create_tween()
		tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 0.15)
		tween.parallel().tween_property(long_hand_rotation, "rotation", final_long_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
	
	# Update lock state after hand movement
	call_deferred("update_lock_state")

# Stop hand from following player (called when level is completed)
func stop_following_player():
	should_follow_player = false
	# Preserve current hand positions for cutscene
	preserved_hand_rotation = short_hand_rotation.rotation
	preserved_long_hand_rotation = long_hand_rotation.rotation
	

# Resume hand following player (called in lobby)
func resume_following_player():
	should_follow_player = true
	

func show_level_complete_cutscene(_next_level_number: int):
	# Stop hand from following player during cutscene
	should_follow_player = false
	
	# HIDE UI DURING CUTSCENE (including game UI elements)
	if ui_handler:
		ui_handler.hide_game_ui_during_cutscene()
		ui_handler.visible = false
	
	# MAKE CUTSCENE VISIBLE - DO NOT RESET HAND POSITION
	visible = true
	
	# HIDE ALL GAMEPLAY ELEMENTS DURING CUTSCENE
	hide_gameplay_elements()
	
	# FORCE SHOW LOCK STATE FIRST for both hands
	if short_hand_clock:
		short_hand_clock.play("lock")
	if long_hand_clock:
		long_hand_clock.play("lock")
		
func hide_cutscene():
	visible = false
	
	# Restore gameplay elements when cutscene is hidden
	show_gameplay_elements()
	
	# SHOW UI AGAIN AFTER CUTSCENE (including game UI elements)
	if ui_handler:
		ui_handler.show_game_ui_after_cutscene()
		ui_handler.visible = true

func hide_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE (skip CanvasLayer and LevelHandler)
	var level_handler = get_parent()  # This is LevelHandler
	var canvas_layer = level_handler.get_parent()  # This is CanvasLayer
	var current_level = canvas_layer.get_parent()  # This is the actual level scene
	
	if current_level:
		# HIDE ALL LEVEL CHILDREN EXCEPT ESSENTIAL ONES AND CANVASLAYER
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = false

func show_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE (skip CanvasLayer and LevelHandler)
	var level_handler = get_parent()  # This is LevelHandler
	var current_level = level_handler.get_parent().get_parent()   # This is the actual level scene
	
	if current_level:
		# RESTORE VISIBILITY OF ALL LEVEL CHILDREN EXCEPT CANVASLAYER
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = true

func get_clock_position_for_level(level_number: int) -> int:
	# Direct 1:1 mapping: level number equals clock position
	# Clamp to valid range 1-12, default to 1 for invalid levels
	if level_number >= 1 and level_number <= 12:
		return level_number
	return 1

func animate_hand_to_next_level(next_clock_position: int) -> Tween:
	# Use the preserved hand positions as starting points
	var current_short_rotation = preserved_hand_rotation if preserved_hand_rotation != 0.0 else short_hand_rotation.rotation
	var current_long_rotation = preserved_long_hand_rotation if preserved_long_hand_rotation != 0.0 else long_hand_rotation.rotation
	var target_rotation = get_rotation_for_clock(next_clock_position)
	
	# Set both hands to preserved positions first
	short_hand_rotation.rotation = current_short_rotation
	long_hand_rotation.rotation = current_long_rotation
	
	# SHOW UNLOCK ANIMATION FIRST BEFORE SLIDING for both hands
	if short_hand_clock:
		short_hand_clock.play("unlock")
	if long_hand_clock:
		long_hand_clock.play("unlock")
	
	# Create a sequence tween that waits first, then slides
	var sequence_tween = create_tween()
	
	# Use tween_callback with a timer instead of tween_delay
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)
	
	# Calculate rotation difference for short hand (minutes)
	var short_rotation_diff = target_rotation - current_short_rotation
	
	# Normalize the difference to find the shortest path first
	while short_rotation_diff > PI:
		short_rotation_diff -= 2 * PI
	while short_rotation_diff < -PI:
		short_rotation_diff += 2 * PI
	
	# If the shortest path is counter-clockwise, make it clockwise instead
	if short_rotation_diff < 0:
		short_rotation_diff += 2 * PI
	
	# Apply the clockwise rotation path for short hand
	var final_short_rotation = current_short_rotation + short_rotation_diff
	
	# Calculate long hand rotations (hours) - full 360° rotations + end at 12 o'clock
	var current_clock_pos = get_clock_position_from_rotation(rad_to_deg(current_long_rotation))
	var hours_to_rotate = calculate_hours_between_positions(current_clock_pos, next_clock_position)
	var long_hand_additional_rotation = hours_to_rotate * 2 * PI  # Full rotations
	
	# Long hand should end at 12 o'clock (0 degrees) after rotations
	var target_long_hand_position = get_rotation_for_clock(12)  # 12 o'clock = 0 degrees
	var final_long_rotation = current_long_rotation + long_hand_additional_rotation
	
	# Adjust final long rotation to land exactly on 12 o'clock
	# Normalize the final rotation to ensure it lands on 12 o'clock
	var normalized_final = fmod(final_long_rotation, 2 * PI)
	if normalized_final < 0:
		normalized_final += 2 * PI
	
	# Calculate additional rotation needed to reach 12 o'clock exactly
	var adjustment_to_12 = target_long_hand_position - normalized_final
	if adjustment_to_12 < 0:
		adjustment_to_12 += 2 * PI
	
	final_long_rotation += adjustment_to_12
	
	# CREATE SMOOTH CUTSCENE ANIMATION - SHORT HAND MOVES TO POSITION, LONG HAND DOES FULL ROTATIONS TO 12
	sequence_tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 2.0)
	sequence_tween.parallel().tween_property(long_hand_rotation, "rotation", final_long_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)
	
	# FORCE SET BASE POSITION AND EXACT ROTATION AFTER ANIMATION
	sequence_tween.finished.connect(func(): 
		base_clock_position = next_clock_position
		var exact_target = get_rotation_for_clock(next_clock_position)
		short_hand_rotation.rotation = exact_target
		long_hand_rotation.rotation = get_rotation_for_clock(12)  # Long hand ends at 12 o'clock
		preserved_hand_rotation = exact_target
		preserved_long_hand_rotation = get_rotation_for_clock(12)  # Preserve 12 o'clock position
		update_lock_state()
	)
	
	return sequence_tween

# New function to calculate hours between clock positions
func calculate_hours_between_positions(_from_pos: int, _to_pos: int) -> int:
	# Always do 1 full rotation (1 hour = 1 full 360° rotation) for any level transition
	return 1

func update_lock_state():
	if not short_hand_clock or not long_hand_clock:
		return
	
	var level_handler = get_parent()
	if not level_handler:
		return
	
	# Get the level number based on CURRENT hand rotation, not base position
	var current_hand_degrees = rad_to_deg(short_hand_rotation.rotation)
	var current_clock_position = get_clock_position_from_rotation(current_hand_degrees)
	var level_for_current_rotation = get_level_for_clock_position(current_clock_position)
	
	# Check if the level at the CURRENT hand position is completed
	if level_for_current_rotation > 0 and level_handler.completed_levels.has(level_for_current_rotation):
		short_hand_clock.play("unlock")
		long_hand_clock.play("unlock")
	else:
		short_hand_clock.play("lock")
		long_hand_clock.play("lock")

# New function to determine clock position from rotation degrees (based on your exact mapping)
func get_clock_position_from_rotation(degrees: float) -> int:
	# Round the degrees to match player's rounding
	var rounded_degrees = round(degrees)
	
	# Normalize degrees to 0-360 range
	var normalized_degrees = fmod(rounded_degrees + 360.0, 360.0)
	
	# Calculate clock position mathematically
	# Each clock position spans 30° (360° / 12 positions)
	# Add 15° offset to center the ranges around each hour mark
	var adjusted_degrees = normalized_degrees + 15.0
	
	# Handle wraparound for 12 o'clock
	if adjusted_degrees >= 360.0:
		adjusted_degrees -= 360.0
	
	# Calculate position: divide by 30° and add 1 (since clock starts at 1, not 0)
	var clock_pos = int(adjusted_degrees / 30.0) + 1
	
	# Handle edge case: clock_pos 13 should be 1 (12 o'clock)
	if clock_pos > 12:
		clock_pos = 1
	
	return clock_pos

func get_level_for_clock_position(clock_position: int) -> int:
	# Direct 1:1 mapping: clock position equals level number
	# Return 0 for invalid positions (unknown level)
	if clock_position >= 1 and clock_position <= 12:
		return clock_position
	return 0

func _on_level_completed(_level_name: String):
	# Update lock state when any level is completed
	update_lock_state()

func _on_level_instantiated(_level_name: String):
	# Update lock state when entering a new level
	call_deferred("update_lock_state")
	# Update lock state when any level is completed
	update_lock_state()

# Function to show level entry cutscene from lobby (generalized for any level)
func show_level_1_entry_cutscene():
	# Stop hand from following player during cutscene
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_during_cutscene()
		ui_handler.visible = false
	
	# Set hands to 12 o'clock position first
	var twelve_oclock_rotation = get_rotation_for_clock(12)
	short_hand_rotation.rotation = twelve_oclock_rotation
	long_hand_rotation.rotation = twelve_oclock_rotation
	
	# MAKE CUTSCENE VISIBLE
	visible = true
	
	# HIDE ALL GAMEPLAY ELEMENTS DURING CUTSCENE
	hide_gameplay_elements()
	
	# FORCE SHOW LOCK STATE FIRST for both hands
	if short_hand_clock:
		short_hand_clock.play("lock")
	if long_hand_clock:
		long_hand_clock.play("lock")

# Function to animate hand from 12 o'clock to 1 o'clock for level 1 entry
func animate_hand_from_12_to_1() -> Tween:
	var current_rotation = get_rotation_for_clock(12)  # 12 o'clock = 0 degrees
	var target_rotation = get_rotation_for_clock(1)    # 1 o'clock = 30 degrees
	
	# Set both hands to 12 o'clock position first
	short_hand_rotation.rotation = current_rotation
	long_hand_rotation.rotation = current_rotation
	
	# SHOW UNLOCK ANIMATION FIRST BEFORE SLIDING for both hands
	if short_hand_clock:
		short_hand_clock.play("unlock")
	if long_hand_clock:
		long_hand_clock.play("unlock")
	
	# Create a sequence tween that waits first, then slides
	var sequence_tween = create_tween()
	
	# Wait before starting the slide animation
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)
	
	# Calculate rotation difference - always go clockwise from 12 to 1
	var rotation_diff = target_rotation - current_rotation  # 30 degrees clockwise
	
	# Apply the clockwise rotation for short hand (minutes hand)
	var final_short_rotation = current_rotation + rotation_diff
	
	# For long hand (hours hand), do a full rotation and end at 12 o'clock
	var long_hand_full_rotation = current_rotation + (2 * PI)  # One full 360° rotation
	
	# CREATE SMOOTH CUTSCENE ANIMATION
	# Short hand moves from 12 to 1 o'clock, long hand does full rotation back to 12
	sequence_tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 2.0)
	sequence_tween.parallel().tween_property(long_hand_rotation, "rotation", long_hand_full_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)
	
	# FORCE SET EXACT POSITIONS AFTER ANIMATION
	sequence_tween.finished.connect(func(): 
		base_clock_position = 1  # Set to 1 o'clock
		short_hand_rotation.rotation = target_rotation  # Short hand at 1 o'clock
		long_hand_rotation.rotation = get_rotation_for_clock(12)  # Long hand back at 12 o'clock
		preserved_hand_rotation = target_rotation
		preserved_long_hand_rotation = get_rotation_for_clock(12)
		update_lock_state()
	)
	
	return sequence_tween


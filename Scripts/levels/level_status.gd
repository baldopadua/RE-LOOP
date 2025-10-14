extends Node2D

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

@onready var short_hand_rotation = $short_hand_rotation
@onready var short_hand_clock = $short_hand_rotation/short_hand_clock
@onready var long_hand_rotation = $long_hand_rotation
@onready var long_hand_clock = $long_hand_rotation/long_hand_clock
var current_player: CharacterBody2D = null
var base_clock_position: int = 12 
var should_follow_player: bool = true 

static var preserved_hand_rotation: float = 0.0
static var preserved_long_hand_rotation: float = 0.0

func _ready() -> void:
	visible = false

# HANDLES SHORT HAND STATE CHANGES FROM LEVEL HANDLER
func _on_short_hand_state_changed(level_number: int, is_unlocked: bool):
	var level_for_current_position = get_level_for_clock_position(base_clock_position)
	if level_number == level_for_current_position:
		if is_unlocked:
			short_hand_clock.play("unlock")
			long_hand_clock.play("unlock")
		else:
			short_hand_clock.play("lock")
			long_hand_clock.play("lock")

func _process(_delta: float) -> void:
	pass

# SETS THE PLAYER REFERENCE
func set_player_reference(player: CharacterBody2D):
	current_player = player

# CALLED WHEN PLAYER MOVES
func _on_player_moved():
	if current_player and short_hand_rotation:
		update_hand_rotation()

# CALCULATES ROTATION ANGLE FOR CLOCK POSITION
func get_rotation_for_clock(clock: int) -> float:
	if clock == 12:
		return 0.0
	return deg_to_rad(clock * 30.0)

# SETS BOTH CLOCK HANDS TO A SPECIFIC CLOCK POSITION
func set_hand_to_clock_position(clock_position: int):
	base_clock_position = clock_position
	var target_rotation = get_rotation_for_clock(clock_position)
	
	short_hand_rotation.rotation = target_rotation
	long_hand_rotation.rotation = target_rotation
	
	preserved_hand_rotation = target_rotation
	preserved_long_hand_rotation = target_rotation
	print("DEBUG: Both hands force set to clock position ", clock_position, " at ", rad_to_deg(target_rotation), " degrees")
	print("DEBUG: Position preserved for cutscene: ", rad_to_deg(preserved_hand_rotation), " degrees")
	
	update_lock_state()

# UPDATES HAND ROTATION BASED ON PLAYER POSITION
func update_hand_rotation():
	if not current_player:
		return
	
	var level_handler = get_parent()
	if not level_handler:
		return
	
	if not should_follow_player:
		return
	
	if level_handler.is_lobby:
		var target_rotation = current_player.rotation
		
		var tween = create_tween()
		tween.parallel().tween_property(short_hand_rotation, "rotation", target_rotation, 0.15)
		tween.parallel().tween_property(long_hand_rotation, "rotation", target_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		
		var current_degrees = rad_to_deg(target_rotation)
		base_clock_position = get_clock_position_from_rotation(current_degrees)
	
	else:
		var player_rotation = current_player.rotation
		var base_rotation = get_rotation_for_clock(base_clock_position)
		var target_hand_rotation = base_rotation + player_rotation
		
		var current_short_rotation = short_hand_rotation.rotation
		var current_long_rotation = long_hand_rotation.rotation
		
		var short_rotation_diff = target_hand_rotation - current_short_rotation
		var long_rotation_diff = target_hand_rotation - current_long_rotation
		
		while short_rotation_diff > PI:
			short_rotation_diff -= 2 * PI
		while short_rotation_diff < -PI:
			short_rotation_diff += 2 * PI
			
		while long_rotation_diff > PI:
			long_rotation_diff -= 2 * PI
		while long_rotation_diff < -PI:
			long_rotation_diff += 2 * PI
		
		var final_short_rotation = current_short_rotation + short_rotation_diff
		var final_long_rotation = current_long_rotation + long_rotation_diff
		
		var tween = create_tween()
		tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 0.15)
		tween.parallel().tween_property(long_hand_rotation, "rotation", final_long_rotation, 0.15)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
	
	call_deferred("update_lock_state")

# STOPS HAND FROM FOLLOWING PLAYER
func stop_following_player():
	should_follow_player = false
	preserved_hand_rotation = short_hand_rotation.rotation
	preserved_long_hand_rotation = long_hand_rotation.rotation

# RESUMES HAND FOLLOWING PLAYER
func resume_following_player():
	should_follow_player = true

# SHOWS LEVEL COMPLETE CUTSCENE
func show_level_complete_cutscene(_next_level_number: int):
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_during_cutscene()
		ui_handler.visible = false
	
	visible = true
	
	hide_gameplay_elements()
	
	if short_hand_clock:
		short_hand_clock.play("lock")
	if long_hand_clock:
		long_hand_clock.play("lock")
		
# HIDES THE CUTSCENE
func hide_cutscene():
	visible = false
	
	show_gameplay_elements()
	
	if ui_handler:
		ui_handler.show_game_ui_after_cutscene()
		ui_handler.visible = true

# HIDES GAMEPLAY ELEMENTS DURING CUTSCENE
func hide_gameplay_elements():
	var level_handler = get_parent()
	var canvas_layer = level_handler.get_parent()
	var current_level = canvas_layer.get_parent()
	
	if current_level:
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = false

# SHOWS GAMEPLAY ELEMENTS AFTER CUTSCENE
func show_gameplay_elements():
	var level_handler = get_parent()
	var current_level = level_handler.get_parent().get_parent()
	
	if current_level:
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = true

# GETS CLOCK POSITION FOR A GIVEN LEVEL NUMBER
func get_clock_position_for_level(level_number: int) -> int:
	if level_number >= 1 and level_number <= 12:
		return level_number
	return 1

# ANIMATES HAND TO NEXT LEVEL POSITION
func animate_hand_to_next_level(next_clock_position: int) -> Tween:
	var current_short_rotation = preserved_hand_rotation if preserved_hand_rotation != 0.0 else short_hand_rotation.rotation
	var current_long_rotation = preserved_long_hand_rotation if preserved_long_hand_rotation != 0.0 else long_hand_rotation.rotation
	var target_rotation = get_rotation_for_clock(next_clock_position)
	
	short_hand_rotation.rotation = current_short_rotation
	long_hand_rotation.rotation = current_long_rotation
	
	if short_hand_clock:
		short_hand_clock.play("unlock")
	if long_hand_clock:
		long_hand_clock.play("unlock")
	
	var sequence_tween = create_tween()
	
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)
	
	var short_rotation_diff = target_rotation - current_short_rotation
	
	while short_rotation_diff > PI:
		short_rotation_diff -= 2 * PI
	while short_rotation_diff < -PI:
		short_rotation_diff += 2 * PI
	
	if short_rotation_diff < 0:
		short_rotation_diff += 2 * PI
	
	var final_short_rotation = current_short_rotation + short_rotation_diff
	
	var current_clock_pos = get_clock_position_from_rotation(rad_to_deg(current_long_rotation))
	var hours_to_rotate = calculate_hours_between_positions(current_clock_pos, next_clock_position)
	var long_hand_additional_rotation = hours_to_rotate * 2 * PI
	
	var target_long_hand_position = get_rotation_for_clock(12)
	var final_long_rotation = current_long_rotation + long_hand_additional_rotation
	
	var normalized_final = fmod(final_long_rotation, 2 * PI)
	if normalized_final < 0:
		normalized_final += 2 * PI
	
	var adjustment_to_12 = target_long_hand_position - normalized_final
	if adjustment_to_12 < 0:
		adjustment_to_12 += 2 * PI
	
	final_long_rotation += adjustment_to_12
	
	sequence_tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 2.0)
	sequence_tween.parallel().tween_property(long_hand_rotation, "rotation", final_long_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)
	
	sequence_tween.finished.connect(func(): 
		base_clock_position = next_clock_position
		var exact_target = get_rotation_for_clock(next_clock_position)
		short_hand_rotation.rotation = exact_target
		long_hand_rotation.rotation = get_rotation_for_clock(12)
		preserved_hand_rotation = exact_target
		preserved_long_hand_rotation = get_rotation_for_clock(12)
		update_lock_state()
	)
	
	return sequence_tween

# CALCULATES HOURS BETWEEN CLOCK POSITIONS
func calculate_hours_between_positions(_from_pos: int, _to_pos: int) -> int:
	return 1

# UPDATES LOCK/UNLOCK STATE OF CLOCK HANDS
func update_lock_state():
	if not short_hand_clock or not long_hand_clock:
		return
	
	var level_handler = get_parent()
	if not level_handler:
		return
	
	var current_hand_degrees = rad_to_deg(short_hand_rotation.rotation)
	var current_clock_position = get_clock_position_from_rotation(current_hand_degrees)
	var level_for_current_rotation = get_level_for_clock_position(current_clock_position)
	
	if level_for_current_rotation > 0 and level_handler.completed_levels.has(level_for_current_rotation):
		short_hand_clock.play("unlock")
		long_hand_clock.play("unlock")
	else:
		short_hand_clock.play("lock")
		long_hand_clock.play("lock")

# CONVERTS ROTATION DEGREES TO CLOCK POSITION
func get_clock_position_from_rotation(degrees: float) -> int:
	var rounded_degrees = round(degrees)
	
	var normalized_degrees = fmod(rounded_degrees + 360.0, 360.0)
	
	var adjusted_degrees = normalized_degrees + 15.0
	
	if adjusted_degrees >= 360.0:
		adjusted_degrees -= 360.0
	
	var clock_pos = int(adjusted_degrees / 30.0) + 1
	
	if clock_pos > 12:
		clock_pos = 1
	
	return clock_pos

# GETS LEVEL NUMBER FOR A GIVEN CLOCK POSITION
func get_level_for_clock_position(clock_position: int) -> int:
	if clock_position >= 1 and clock_position <= 12:
		return clock_position
	return 0

# HANDLES LEVEL COMPLETION
func _on_level_completed(_level_name: String):
	update_lock_state()

# HANDLES LEVEL INSTANTIATION
func _on_level_instantiated(_level_name: String):
	call_deferred("update_lock_state")
	update_lock_state()

# SHOWS LEVEL 1 ENTRY CUTSCENE
func show_level_1_entry_cutscene():
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_during_cutscene()
		ui_handler.visible = false
	
	var twelve_oclock_rotation = get_rotation_for_clock(12)
	short_hand_rotation.rotation = twelve_oclock_rotation
	long_hand_rotation.rotation = twelve_oclock_rotation
	
	visible = true
	
	hide_gameplay_elements()
	
	if short_hand_clock:
		short_hand_clock.play("lock")
	if long_hand_clock:
		long_hand_clock.play("lock")

# ANIMATES HAND FROM 12 TO 1 O'CLOCK
func animate_hand_from_12_to_1() -> Tween:
	var current_rotation = get_rotation_for_clock(12)
	var target_rotation = get_rotation_for_clock(1)
	
	short_hand_rotation.rotation = current_rotation
	long_hand_rotation.rotation = current_rotation
	
	if short_hand_clock:
		short_hand_clock.play("unlock")
	if long_hand_clock:
		long_hand_clock.play("unlock")
	
	var sequence_tween = create_tween()
	
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)
	
	var rotation_diff = target_rotation - current_rotation
	
	var final_short_rotation = current_rotation + rotation_diff
	
	var long_hand_full_rotation = current_rotation + (2 * PI)
	
	sequence_tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 2.0)
	sequence_tween.parallel().tween_property(long_hand_rotation, "rotation", long_hand_full_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)
	
	sequence_tween.finished.connect(func(): 
		base_clock_position = 1
		short_hand_rotation.rotation = target_rotation
		long_hand_rotation.rotation = get_rotation_for_clock(12)
		preserved_hand_rotation = target_rotation
		preserved_long_hand_rotation = get_rotation_for_clock(12)
		update_lock_state()
	)
	
	return sequence_tween


# LEVEL STATUS: HANDLES CLOCK HANDS, CUTSCENES, ROTATION AND ANIMATION HELPERS

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
static var preserved_rotations_valid: bool = false

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


@onready var objects: Array = []

func _ready() -> void:
	visible = false
	objects_initialize()
	# Force update of entrance visuals on ready
	var level_handler = get_parent()
	if level_handler and "completed_levels" in level_handler:
		update_completed_levels_visual(level_handler.completed_levels)

func objects_initialize():
	for i in range(1, 13):
		var entrance_var_name = "enter_" + str(i)
		var entrance = get(entrance_var_name)
		if entrance:
			objects.append(entrance)

func update_completed_levels_visual(completed_levels: Array):
	for level_num in range(1, 13):
		var is_completed = completed_levels.has(level_num)
		var entrance_var_name = "enter_" + str(level_num)
		var entrance = get_node_or_null(entrance_var_name)
		if entrance and entrance.has_method("set_level_completion_visual"):
			entrance.set_level_completion_visual(is_completed)

func set_level_completion_visual(is_completed: bool):
	if has_node("Sprite2D2"):
		var sprite = get_node("Sprite2D2")
		if is_completed:
			sprite.modulate = Color(0, 1, 0) # Green
		else:
			sprite.modulate = Color(1, 1, 1) # Default

func _on_short_hand_state_changed(_level_number: int, _is_unlocked: bool):
	pass

func _process(_delta: float) -> void:
	pass

func set_player_reference(player: CharacterBody2D):
	current_player = player

func _on_player_moved():
	if current_player and short_hand_rotation:
		update_hand_rotation()

func get_rotation_for_clock(clock: int) -> float:
	if clock == 12:
		return 0.0
	return deg_to_rad(clock * 30.0)

func set_hand_to_clock_position(clock_position: int):
	base_clock_position = clock_position
	var target_rotation = get_rotation_for_clock(clock_position)
	
	short_hand_rotation.rotation = target_rotation
	long_hand_rotation.rotation = target_rotation
	
	preserved_hand_rotation = target_rotation
	preserved_long_hand_rotation = target_rotation
	preserved_rotations_valid = true
	print("DEBUG: Both hands force set to clock position ", clock_position, " at ", rad_to_deg(target_rotation), " degrees")
	print("DEBUG: Position preserved for cutscene: ", rad_to_deg(preserved_hand_rotation), " degrees")
	

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
	

func stop_following_player():
	should_follow_player = false
	preserved_hand_rotation = short_hand_rotation.rotation
	preserved_long_hand_rotation = long_hand_rotation.rotation
	preserved_rotations_valid = true

func resume_following_player():
	should_follow_player = true
	preserved_rotations_valid = false

func show_level_complete_cutscene(_next_level_number: int):
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_elements()
		ui_handler.visible = false
	
	visible = true
	hide_gameplay_elements()
	
	
func hide_cutscene():
	visible = false
	show_gameplay_elements()
	
	if ui_handler:
		ui_handler.show_game_ui_after_cutscene()
		ui_handler.visible = true

	

func hide_gameplay_elements():
	var level_handler = get_parent()
	var canvas_layer = level_handler.get_parent()
	var current_level = canvas_layer.get_parent()
	
	if current_level:
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = false

func show_gameplay_elements():
	var level_handler = get_parent()
	var current_level = level_handler.get_parent().get_parent()
	
	if current_level:
		for child in current_level.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = true

func get_clock_position_for_level(level_number: int) -> int:
	if level_number >= 1 and level_number <= 12:
		return level_number
	return 1

func animate_hand_to_next_level(next_clock_position: int) -> Tween:
	var sound_manager = get_tree().root.find_child("SoundManager", true, false)
	if sound_manager:
		sound_manager.play_sfx("clock_transition")
	
	var current_short_rotation = preserved_hand_rotation if preserved_rotations_valid else short_hand_rotation.rotation
	var current_long_rotation = preserved_long_hand_rotation if preserved_rotations_valid else long_hand_rotation.rotation
	var target_short_rotation = get_rotation_for_clock(next_clock_position)
	
	short_hand_rotation.rotation = current_short_rotation
	long_hand_rotation.rotation = current_long_rotation

	var sequence_tween = create_tween()
	sequence_tween.tween_callback(func(): await get_tree().create_timer(0.5).timeout)

	var start_short_clock_pos = get_clock_position_from_rotation(rad_to_deg(current_short_rotation))
	var direction = 1
	if next_clock_position < start_short_clock_pos:
		direction = -1

	var short_diff = target_short_rotation - current_short_rotation
	while short_diff > PI:
		short_diff -= 2 * PI
	while short_diff < -PI:
		short_diff += 2 * PI

	if direction == -1 and short_diff > 0:
		short_diff -= 2 * PI
	if direction == 1 and short_diff < 0:
		short_diff += 2 * PI

	var final_short_rotation = current_short_rotation + short_diff

	var current_long_clock_pos = get_clock_position_from_rotation(rad_to_deg(current_long_rotation))
	var signed_hours = next_clock_position - current_long_clock_pos
	if direction == 1:
		if signed_hours <= 0:
			signed_hours += 12
	else:
		if signed_hours >= 0:
			signed_hours -= 12

	var long_hand_additional_rotation = signed_hours * (2 * PI)
	var final_long_rotation = current_long_rotation + long_hand_additional_rotation

	var normalized_final = fmod(final_long_rotation, 2 * PI)
	if normalized_final < 0:
		normalized_final += 2 * PI

	var adjustment_to_12 = -normalized_final
	if adjustment_to_12 < 0:
		adjustment_to_12 += 2 * PI
	final_long_rotation += adjustment_to_12

	sequence_tween.parallel().tween_property(short_hand_rotation, "rotation", final_short_rotation, 2.0)
	sequence_tween.parallel().tween_property(long_hand_rotation, "rotation", final_long_rotation, 2.0)
	sequence_tween.set_trans(Tween.TRANS_QUART)
	sequence_tween.set_ease(Tween.EASE_IN_OUT)

	sequence_tween.finished.connect(func():
		base_clock_position = next_clock_position
		short_hand_rotation.rotation = get_rotation_for_clock(next_clock_position)
		long_hand_rotation.rotation = get_rotation_for_clock(12)
		preserved_hand_rotation = get_rotation_for_clock(next_clock_position)
		preserved_long_hand_rotation = get_rotation_for_clock(12)
		preserved_rotations_valid = true
	)
	
	return sequence_tween

func calculate_hours_between_positions(_from_pos: int, _to_pos: int) -> int:
	var f = ((_from_pos - 1) % 12) + 1
	var t = ((_to_pos - 1) % 12) + 1
	var diff = t - f
	if diff <= 0:
		diff += 12
	return diff

func update_lock_state():
	pass

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

func get_level_for_clock_position(clock_position: int) -> int:
	if clock_position >= 1 and clock_position <= 12:
		return clock_position
	return 0

func _on_level_completed(_level_name: String):
	update_lock_state()
	# Update entrance visuals to match completed levels
	var level_handler = get_parent()
	if level_handler and "completed_levels" in level_handler:
		update_completed_levels_visual(level_handler.completed_levels)

func _on_level_instantiated(_level_name: String):
	call_deferred("update_lock_state")
	update_lock_state()
	# Update entrance visuals to match completed levels
	var level_handler = get_parent()
	if level_handler and "completed_levels" in level_handler:
		update_completed_levels_visual(level_handler.completed_levels)

func show_level_1_entry_cutscene():
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_elements()
		ui_handler.visible = false
	
	var twelve_oclock_rotation = get_rotation_for_clock(12)
	short_hand_rotation.rotation = twelve_oclock_rotation
	long_hand_rotation.rotation = twelve_oclock_rotation
	
	visible = true
	hide_gameplay_elements()
	
	# Show animated bg, hide static bg (back to normal during clock animation)
	var game_scene = get_tree().root.get_node("MainScene/GameScene")
	if game_scene and game_scene.has_node("CanvasLayer/bg") and game_scene.has_node("CanvasLayer/game_scene_bg"):
		game_scene.get_node("CanvasLayer/bg").visible = false
		game_scene.get_node("CanvasLayer/game_scene_bg").visible = true

func show_level_entry_cutscene():
	should_follow_player = false
	
	if ui_handler:
		ui_handler.hide_game_ui_elements()
		ui_handler.visible = false
	
	visible = true
	hide_gameplay_elements()
	
	# Show animated bg, hide static bg (back to normal during clock animation)
	var game_scene = get_tree().root.get_node("MainScene/GameScene")
	if game_scene and game_scene.has_node("CanvasLayer/bg") and game_scene.has_node("CanvasLayer/game_scene_bg"):
		game_scene.get_node("CanvasLayer/bg").visible = false
		game_scene.get_node("CanvasLayer/game_scene_bg").visible = true

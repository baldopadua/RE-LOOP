# LEVEL HANDLER: MANAGES MAP, LEVEL LOADING, TRANSITIONS, COMPLETION, AND HINT SIGNALS

extends Node2D

signal level_instantiated(level_name: String)
signal level_completed(level_name: String)
signal short_hand_state_changed(level_number: int, is_unlocked: bool)
signal map_scale_tween_finished() 
signal hint_level_changed(level_number: int)
signal skip_level_requested(level_number: int) # <--- ADD THIS LINE
signal lobby_returned # Notify GameScene when lobby is returned

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
var player = null

var current_level_number: int = 0
var current_player: CharacterBody2D = null
var is_lobby: bool = false
var is_replaying_completed_level: bool = false
static var completed_levels: Array[int] = []
const TOTAL_LEVEL_COUNT: int = 12
@onready var level_status_node = $level_status

var hint_component = null
var pre_entry_clock_pos: int = 12
static var last_entered_level: int = 0
# NOTE: This flag is used to indicate the last level number the player entered (used by the lobby to place player back on the clock).
static var last_play_was_replay: bool = false

var initializing_map_node: Node = null

func map_initialize(this, tween_rotate, tween_scale):
	initializing_map_node = this
	if initializing_map_node and "visible" in initializing_map_node:
		initializing_map_node.visible = false

	GlobalVariables.is_looping = true
	GlobalVariables.player_stopped = false

	this.rotation = deg_to_rad(360.0)
	this.scale = Vector2(0.01, 0.01)

	tween_rotate = create_tween()
	tween_rotate.connect("finished", Callable(self, "tween_rotate_finished").bind(tween_rotate))

	var rotation_tween = rotation - deg_to_rad(360.0)
	tween_rotate.tween_property(this, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween_scale = create_tween()
	tween_scale.connect("finished", Callable(self, "tween_scale_finished").bind(tween_scale))
	tween_scale.tween_property(this, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	map_scale_tween_finished.emit()

	if not short_hand_state_changed.is_connected(level_status_node._on_short_hand_state_changed):
		short_hand_state_changed.connect(level_status_node._on_short_hand_state_changed)

	
func tween_rotate_finished(tween_created):
	print("Rotate Killed")
	tween_created.kill()

func tween_scale_finished(tween_created):
	print("Scale Killed")
	tween_created.kill()
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
	
	var old_children: Array = []
	if levels_frame:
		for child in levels_frame.get_children():
			old_children.append(child)
			if "visible" in child:
				child.visible = false
	
	var new_level = load(scene_path).instantiate()
	if new_level:
		if "visible" in new_level:
			new_level.visible = false
		levels_frame.add_child(new_level)
	
	await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	
	if new_level and "visible" in new_level:
		new_level.visible = true
	
	for child in old_children:
		if child and child.is_inside_tree():
			child.queue_free()

func set_current_level(level_number: int):
	current_level_number = level_number
	is_lobby = false
	
	is_replaying_completed_level = completed_levels.has(level_number)
	last_play_was_replay = is_replaying_completed_level
	
	var level_name = "level_" + str(level_number)
	print("Level Handler: Current level set to ", level_name)
	if is_replaying_completed_level:
		print("Level Handler: This is a replay of an already completed level")
	
	emit_signal("level_instantiated", level_name)
	emit_signal("hint_level_changed", level_number)

func set_current_lobby():
	current_level_number = 0
	is_lobby = true
	print("Level Handler: Current scene set to lobby")
	emit_signal("level_instantiated", "lobby")
	
	level_status_node.resume_following_player()
	emit_signal("hint_level_changed", 0)
	

func complete_current_level(levels_frame):
	# Always hide hint and timer when any level is completed
	if ui_handler:
		ui_handler.hide_and_disable_hint_and_time()
	
	if current_level_number > 0:
		var current_level = levels_frame.get_child(0)
		if current_level:
			_kill_all_level_tweens(current_level)
		
		if current_player:
			GlobalVariables.player_stopped = true
			current_player.set_physics_process(false)
			current_player.set_process_input(false)
		
		if ui_handler and ui_handler.has_node("ui_logic/overlay/hint"):
			var hint = ui_handler.get_node("ui_logic/overlay/hint")
			var hint_2_timer = hint.get_node_or_null("hint_box/hint_box_empty/hint_2/hint_2_timer")
			var solution_timer = hint.get_node_or_null("hint_box/hint_box_empty/solution/solution_timer")
			
			if hint_2_timer:
				hint_2_timer.stop()
			if solution_timer:
				solution_timer.stop()
		
		level_status_node.stop_following_player()
		
		match current_level_number:
			1:
				level_status_node.set_hand_to_clock_position(1)
			2:
				level_status_node.set_hand_to_clock_position(2)
			3:
				level_status_node.set_hand_to_clock_position(3)
			4:
				level_status_node.set_hand_to_clock_position(4)
			5:
				level_status_node.set_hand_to_clock_position(5)
			6:
				level_status_node.set_hand_to_clock_position(6)
			7:
				level_status_node.set_hand_to_clock_position(7)
			8:
				level_status_node.set_hand_to_clock_position(8)
			9:
				level_status_node.set_hand_to_clock_position(9)
			10:
				level_status_node.set_hand_to_clock_position(10)
			11:
				level_status_node.set_hand_to_clock_position(11)
			12:
				level_status_node.set_hand_to_clock_position(12)
			_:
				level_status_node.set_hand_to_clock_position(1)
		
		var level_name = "level_" + str(current_level_number)
		emit_signal("level_completed", level_name)
		
		if not is_replaying_completed_level:
			_mark_level_completed_and_print_status()
		
		kill_current_level(current_level)
		ui_handler.enable_game_ui_elements()
		# Play crystal sound when player enters loop break portal
		var area_handler_node = current_level.get_node_or_null("AreaHandler")
		if area_handler_node:
			var sound_mgr = area_handler_node.get_node_or_null("SoundManager")
			if sound_mgr and sound_mgr.sfx.has("crystal_sfx"):
				sound_mgr.play_sfx("crystal_sfx")
		await get_tree().create_timer(0.7).timeout

		var next_level_number = current_level_number + 1
		if next_level_number > TOTAL_LEVEL_COUNT:
			next_level_number = 1

		if is_replaying_completed_level:
			print("Level Handler: Replay completed level - returning to lobby")
			await return_to_lobby(levels_frame)
			await get_tree().create_timer(0.12).timeout
			var lobby_scene = levels_frame.get_child(0)
			if lobby_scene and lobby_scene.has_method("start_replay_return_animation"):
				var target_pos = last_entered_level if last_entered_level > 0 else current_level_number
				
				lobby_scene.start_replay_return_animation(current_level_number, target_pos)
			return
		else:
			# --- NEW LOGIC: show comic cutscene after level 12 completion ---
			if current_level_number == 12 and ui_handler:
				ui_handler.show_level_cutscene(12, func(): await return_to_lobby(levels_frame))
				return
			await return_to_lobby(levels_frame)
			# --- REMOVE/COMMENT OUT THE CUTSCENE LOGIC BELOW ---
			# var lobby_scene = levels_frame.get_child(0)
			# if lobby_scene and lobby_scene.has_method("start_cutscene_then_enter_next_level"):
			# 	lobby_scene.start_cutscene_then_enter_next_level(next_level_number)
			# else:
			# 	if ui_handler:
			# 		ui_handler.show_level_cutscene(next_level_number, func(): _continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame))
			# 	else:
			# 		_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)
			# --- NOW, JUST RETURN TO LOBBY ---
			return
		# if ui_handler:
		# 	ui_handler.show_level_cutscene(next_level_number, func(): _continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame))
		# else:
		# 	_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)

func _show_clock_then_return_lobby(_cutscene_level_number: int, levels_frame):
	await show_level_transition_cutscene(_cutscene_level_number)
	return_to_lobby(levels_frame)

func _show_clock_then_load_level(next_level_number: int, levels_frame):
	await show_level_transition_cutscene(next_level_number)
	_continue_to_level("res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn", levels_frame)

func load_next_level_directly(next_level_number: int, levels_frame):
	var next_level_path = "res://Scenes/levels/level_" + str(next_level_number) + "_scene.tscn"
	if ResourceLoader.exists(next_level_path):
		_continue_to_level(next_level_path, levels_frame)
	else:
		print("Level Handler: Level ", next_level_number, " scene file not found, returning to lobby")
		return_to_lobby(levels_frame)

func _continue_to_level(level_path: String, levels_frame):
	ui_handler.show_and_enable_hint_and_time()
	GlobalVariables.player_moves = 0
	change_level(level_path, levels_frame)
	ui_handler.set_default_time_indicator()
	ui_handler.visible = true

func return_to_lobby(levels_frame):
	GlobalVariables.player_moves = 0
	
	var lobby_path = "res://Scenes/levels/level_lobby.tscn"
	change_level(lobby_path, levels_frame)
	emit_signal("lobby_returned")
	ui_handler.set_default_time_indicator()
	if is_replaying_completed_level:
		level_status_node.preserved_hand_rotation = 0.0
		level_status_node.resume_following_player()
	
	await get_tree().create_timer(0.1).timeout  
	var lobby_scene = levels_frame.get_child(0)
	if lobby_scene and lobby_scene.has_node("SoundManager"):
		var sound_manager = lobby_scene.get_node("SoundManager")
		sound_manager.play_ambience_music("space_ambience")

	if ui_handler:
		print("Calling show_game_ui_elements from return_to_lobby")
		ui_handler.show_game_ui_elements()

func _mark_level_completed_and_print_status():
	if not completed_levels.has(current_level_number):
		completed_levels.append(current_level_number)
	print_completion_status()
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)

func print_completion_status():
	var completed_status = ""
	for i in range(1, TOTAL_LEVEL_COUNT + 1):
		if completed_levels.has(i):
			completed_status += "level " + str(i) + " ✓, "
		else:
			completed_status += "level " + str(i) + " ✗, "
	
	completed_status = completed_status.trim_suffix(", ")
	print("Level Handler: ", completed_status)
	

func update_short_hand_state_for_level(_level_number: int):
	pass

func show_level_transition_cutscene(next_level_number: int):
	level_status_node.show_level_complete_cutscene(next_level_number)
	await get_tree().create_timer(1.0).timeout
	var next_level_clock_position = level_status_node.get_clock_position_for_level(next_level_number)
	var animation_tween = level_status_node.animate_hand_to_next_level(next_level_clock_position)
	if animation_tween:
		await animation_tween.finished
	await get_tree().create_timer(1.0).timeout
	level_status_node.hide_cutscene()

func restart_level(levels_frame):
	var current_level = levels_frame.get_child(0)
	if current_level:
		var level_scene = load(current_level.scene_file_path) 
		current_level.queue_free()
		var new_level = level_scene.instantiate()
		levels_frame.add_child(new_level)

func kill_current_level(level_scene):
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
	tween_scale.tween_property(level_scene, "scale", Vector2(0.01, 0.01), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

func _kill_all_level_tweens(level_scene: Node):
	_recursive_kill_tweens(level_scene)
	
	var tweens = get_tree().get_nodes_in_group("tweens")
	for tween in tweens:
		if tween and tween.is_valid():
			tween.kill()

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

# Listener function to be connected to a UI/Control node signal
func on_ui_request_return_to_lobby(levels_frame):
	# Kill current level if exists
	if levels_frame and levels_frame.get_child_count() > 0:
		var current_level = levels_frame.get_child(0)
		if current_level:
			kill_current_level(current_level)
	# Switch to lobby
	await return_to_lobby(levels_frame)

# Listener for skip button or script call: completes level and returns to lobby
func on_skip_level_and_return_to_lobby(levels_frame):
	if current_level_number > 0:
		await complete_current_level(levels_frame)
		# Optionally, you can add extra logic here if needed

func request_skip_level():
	emit_signal("skip_level_requested", current_level_number)


func _on_tree_level_1_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(1):
		completed_levels.append(1)
		print("Level 1 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)


func _on_sword_level_2_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(2):
		completed_levels.append(2)
		print("Level 2 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)


func _on_geyser_level_3_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(3):
		completed_levels.append(3)
		print("Level 3 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)


func _on_level_4_level_4_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(4):
		completed_levels.append(4)
		print("Level 4 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)


func _on_level_5_level_5_completed() -> void:
	ui_handler.show_game_ui_elements()
	# --- Ensure hint and time are hidden visually ---
	var game_ui = ui_handler.ui_logic.get_node_or_null("game_ui_elements")
	if game_ui:
		var hint_btn = game_ui.get_node_or_null("hint_button")
		if hint_btn:
			hint_btn.visible = false
		var time_node = game_ui.get_node_or_null("time")
		if time_node:
			time_node.visible = false
	# ...existing code...
	if not completed_levels.has(5):
		completed_levels.append(5)
		print("Level 4 marked as completed via tree signal.")
	# ...existing code...
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)

func _on_level_6_scene_level_6_completed() -> void:
	ui_handler.show_game_ui_elements()
	# --- Ensure hint and time are hidden visually ---
	var game_ui = ui_handler.ui_logic.get_node_or_null("game_ui_elements")
	if game_ui:
		var hint_btn = game_ui.get_node_or_null("hint_button")
		if hint_btn:
			hint_btn.visible = false
		var time_node = game_ui.get_node_or_null("time")
		if time_node:
			time_node.visible = false
	# ...existing code...
	if not completed_levels.has(6):
		completed_levels.append(6)
		print("Level 6 marked as completed via tree signal.")
	# ...existing code...
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)

func _on_wind_level_7_completed() -> void:
	ui_handler.show_game_ui_elements()
	# --- Ensure hint and time are hidden visually ---
	var game_ui = ui_handler.ui_logic.get_node_or_null("game_ui_elements")
	if game_ui:
		var hint_btn = game_ui.get_node_or_null("hint_button")
		if hint_btn:
			hint_btn.visible = false
		var time_node = game_ui.get_node_or_null("time")
		if time_node:
			time_node.visible = false
	# ...existing code...
	if not completed_levels.has(7):
		completed_levels.append(7)
		print("Level 7 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)


func _on_gun_level_8_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(8):
		completed_levels.append(8)
		print("Level 8 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)

func _on_laser_level_10_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(10):
		completed_levels.append(10)
		print("Level 8 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)

func _on_level_12_scene_level_12_completed() -> void:
	ui_handler.show_game_ui_elements()
	if not completed_levels.has(12):
		completed_levels.append(12)
		print("Level 8 marked as completed via tree signal.")
	# Update clock entrance visuals immediately
	if level_status_node and level_status_node.has_method("update_completed_levels_visual"):
		level_status_node.update_completed_levels_visual(completed_levels)
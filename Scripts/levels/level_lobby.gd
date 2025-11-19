# LOBBY LOGIC: MANAGES ENTRANCES, PLAYER PLACEMENT, CUTSCENES AND TRANSITIONS

extends Node2D

@export var source_tilemap: TileMapLayer

@onready var objects: Array = []

@onready var player = $PlayerScene

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager

var ui_handler = null

var lobby_active: bool = true

var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0, 0)

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
@onready var enter_13: object_class = null
@onready var short_hand_rotation_lobby = $short_hand_rotation_lobby

var clock_area: int = 12
var highest_completed_level = 0

# FOR JUMP ANIMATION DURING LEVEL LOBBY
const REPLAY_INITIAL_PAUSE: float = 0.8
const JUMP_RISE_TIME: float = 0.12
const JUMP_FALL_TIME: float = 0.14
const BETWEEN_JUMPS_DELAY: float = 0.18
const JUMP_LIFT_Y: float = 24
const ANIM_SPEED_MULTIPLIER: float = 1.8

func _ready():
	await get_tree().process_frame
	lobby_active = true
    
	call_deferred("initialize_text_labels")
	ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")
	ui_handler.hide_and_disable_hint_and_time()
	var game_scene = get_tree().root.get_node("MainScene/GameScene")
	if game_scene and game_scene.has_node("CanvasLayer/bg") and game_scene.has_node("CanvasLayer/game_scene_bg"):
		game_scene.get_node("CanvasLayer/bg").visible = true
		game_scene.get_node("CanvasLayer/game_scene_bg").visible = false

	
	if level_handler:
		level_handler.set_current_lobby()
	else:
		print("Error: level_handler not found")
		return
		
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	level_handler.level_status_node.get_node("clock_base").visible = true
	
	level_handler.visible = false

	objects_initialize()
	call_deferred("update_completed_levels_visual")
	
	level_handler.level_completed.connect(_on_level_completed)
	
	call_deferred("position_player_based_on_progress")
	sound_manager.play_ambience_music("space_ambience")
	
	GlobalVariables.is_looping = false
	GlobalVariables.player_moves = 0

	# --- NEW: Set all entrances to not enterable by default ---
	for obj in objects:
		if obj:
			obj.is_enterable = false

func initialize_text_labels():
	var entrances = [enter_1, enter_2, enter_3, enter_4, enter_5, enter_6, enter_7, enter_8, enter_9, enter_10, enter_11, enter_12]
	for entrance in entrances:
		if entrance and entrance.has_node("hover_text"):
			var hover_label = entrance.get_node("hover_text")
			hover_label.visible = false
			
		if entrance and entrance.has_node("interact_text"):
			var interact_label = entrance.get_node("interact_text")
			interact_label.visible = false

func objects_initialize():
	for i in range(1, 13):
		var entrance_var_name = "enter_" + str(i)
		var entrance = get(entrance_var_name)
		if entrance:
			objects.append(entrance)

func _process(_delta: float) -> void:
	if not lobby_active:
		return
	level_handler.visible = true
	# --- Sync short_hand_rotation_lobby to player rotation ---
	if player and short_hand_rotation_lobby:
		short_hand_rotation_lobby.rotation = player.rotation

func enter_level(level_number: int):
	if level_handler:
		level_handler.last_entered_level = level_number
	
	disable_lobby_functionality()
	print("Entering level ", level_number)
	
	var level_path = "res://Scenes/levels/level_" + str(level_number) + "_scene.tscn"
	if not ResourceLoader.exists(level_path):
		print("Level ", level_number, " is not ready yet!")
		enable_lobby_functionality()
		return  
	
	sound_manager.stop_ambience_music("space_ambience")
	var levels_frame = get_parent() 

	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# --- NEW LOGIC: skip comic for level 12 ---
	if level_number == 12:
		# Directly show clock animation then load level 12
		await _show_clock_animation_then_level(level_number, levels_frame)
	else:
		if ui_handler:
			ui_handler.show_level_cutscene(level_number, func(): _show_clock_animation_then_level(level_number, levels_frame))
		else:
			await _show_clock_animation_then_level(level_number, levels_frame)

func _show_clock_animation_then_level(level_number: int, levels_frame):
	print("Showing clock animation for level ", level_number)
	level_handler.level_status_node.get_node("clock_base").visible = true

	# Show animated bg, hide static bg (back to normal during clock animation)
	var game_scene = get_tree().root.get_node("MainScene/GameScene")
	if game_scene and game_scene.has_node("CanvasLayer/bg") and game_scene.has_node("CanvasLayer/game_scene_bg"):
		game_scene.get_node("CanvasLayer/bg").visible = false
		game_scene.get_node("CanvasLayer/game_scene_bg").visible = true

	for lvl in level_handler.completed_levels:
		if lvl > highest_completed_level:
			highest_completed_level = lvl
	var start_hand_pos = highest_completed_level if highest_completed_level > 0 else 12
	level_handler.level_status_node.set_hand_to_clock_position(start_hand_pos)

	level_handler.level_status_node.show_level_entry_cutscene()
	await get_tree().create_timer(1.0).timeout
	
	var target_clock_position = level_handler.level_status_node.get_clock_position_for_level(level_number)
	var animation_tween = level_handler.level_status_node.animate_hand_to_next_level(target_clock_position)
	if animation_tween:
		await animation_tween.finished
	
	await get_tree().create_timer(1.0).timeout
	level_handler.level_status_node.hide_cutscene()
	
	# Restore animated bg, hide static bg (game background)
	if game_scene and game_scene.has_node("CanvasLayer/bg") and game_scene.has_node("CanvasLayer/game_scene_bg"):
		game_scene.get_node("CanvasLayer/bg").visible = false
		game_scene.get_node("CanvasLayer/game_scene_bg").visible = true
	
	ui_handler.show_game_ui_elements()
	
	level_handler.load_next_level_directly(level_number, levels_frame)

func update_completed_levels_visual():
	print("Updating completed levels visual...")
	print("Completed levels: ", level_handler.completed_levels)
	
	for level_num in range(1, 13):
		var is_completed = level_handler.completed_levels.has(level_num)
		print("Level ", level_num, " - Completed: ", is_completed)
		
		var entrance_var_name = "enter_" + str(level_num)
		var entrance = get(entrance_var_name)
		
		if entrance:
			entrance.set_level_completion_visual(is_completed)

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


# helper: perform one jump animation to a target clock level
func _jump_to_level_once(target_level: int, anim_node: AnimatedSprite2D = null, disable_player: bool = true, anim_speed: float = ANIM_SPEED_MULTIPLIER) -> void:
	# optionally disable player processing during the jump
	if disable_player and player:
		player.set_process(false)
		player.set_physics_process(false)
		player.set_process_input(false)
		GlobalVariables.player_stopped = true

	# find anim node if not provided
	if anim_node == null and player and player.has_node("AnimatedSprite2D"):
		anim_node = player.get_node("AnimatedSprite2D")

	# set animation speed if requested (use negative to skip)
	if anim_node and anim_speed >= 0.0:
		anim_node.speed_scale = anim_speed

	if anim_node:
		anim_node.play("jump")

	# Fade out + rise
	var fade_out = create_tween()
	fade_out.tween_property(player, "position:y", player.position.y - JUMP_LIFT_Y, JUMP_RISE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_out.parallel().tween_property(player, "self_modulate:a", 0.0, JUMP_RISE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await fade_out.finished

	# Rotate to target and update clock hand
	player.rotation = deg_to_rad(target_level * 30)
	if level_handler and level_handler.level_status_node:
		level_handler.level_status_node.set_hand_to_clock_position(target_level)

	# Fade in + fall
	var fade_in = create_tween()
	fade_in.tween_property(player, "position:y", player.position.y + JUMP_LIFT_Y, JUMP_FALL_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_in.parallel().tween_property(player, "self_modulate:a", 1.0, JUMP_FALL_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await fade_in.finished

	if anim_node:
		await anim_node.animation_finished
		if anim_speed >= 0.0:
			anim_node.speed_scale = 1.0
			anim_node.play("idle")

	if disable_player and player:
		player.set_process(true)
		player.set_physics_process(true)
		player.set_process_input(true)
		GlobalVariables.player_stopped = false


func position_player_based_on_progress():
	if not player:
		return

	if level_handler and level_handler.last_play_was_replay and level_handler.last_entered_level > 0:
		var replay_pos = level_handler.last_entered_level

		# --- DISABLE PLAYER MOVEMENT DURING REPLAY RETURN SEQUENCE ---
		if player:
			player.set_process(false)
			player.set_physics_process(false)
			player.set_process_input(false)
		GlobalVariables.player_stopped = true
	

		player.rotation = deg_to_rad(replay_pos * 30)
		if level_handler and level_handler.level_status_node:
			level_handler.level_status_node.set_hand_to_clock_position(replay_pos)

		await get_tree().create_timer(REPLAY_INITIAL_PAUSE).timeout

		# determine highest completed level
		for lvl in level_handler.completed_levels:
			if lvl > highest_completed_level:
				highest_completed_level = lvl

		# compute next available level (wrap from 12->1)
		var next_pos = (highest_completed_level + 1) if highest_completed_level > 0 else 1
		if next_pos > 12:
			next_pos = 1

		# ensure we actually move to the next position (edge-case)
		if next_pos == replay_pos:
			next_pos += 1
			if next_pos > 12:
				next_pos = 1

		# prepare animation node
		var anim_node = null
		if player.has_node("AnimatedSprite2D"):
			anim_node = player.get_node("AnimatedSprite2D")
		
		if anim_node:
			anim_node.speed_scale = ANIM_SPEED_MULTIPLIER

		# perform jumps from the completed level to the next available level
		var current = replay_pos
		while current != next_pos:
			current += 1
			if current > 12:
				current = 1

			await _jump_to_level_once(current, anim_node, false, -1)

		if anim_node:
			anim_node.speed_scale = 1.0
			anim_node.play("idle")

		if player:
			player.set_process(true)
			player.set_physics_process(true)
			player.set_process_input(true)
		GlobalVariables.player_stopped = false

		level_handler.last_play_was_replay = false
		level_handler.last_entered_level = 0
		return
		
	for level_num in level_handler.completed_levels:
		if level_num > highest_completed_level:
			highest_completed_level = level_num
	
	var target_rotation = 0.0
	
	if highest_completed_level == 0:
		target_rotation = deg_to_rad(360.0)
		level_handler.level_status_node.set_hand_to_clock_position(12)
		player.rotation = target_rotation
		
	else:
		var next_level = highest_completed_level + 1
		if next_level > 12:
			next_level = 1
		target_rotation = deg_to_rad(next_level * 30)
		level_handler.level_status_node.set_hand_to_clock_position(highest_completed_level)
	player.rotation = target_rotation

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
			obj.is_enterable = false # <--- Disable enterable when lobby is not active
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

func enable_lobby_functionality():
	lobby_active = true
	
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
			obj.is_enterable = true # <--- Enable enterable only when lobby is active
	
	if level_handler:
		level_handler.set_process(true)
	
	if sound_manager:
		sound_manager.set_process(true)

func start_cutscene_then_enter_next_level(next_level_number: int):
	disable_lobby_functionality()
	
	if sound_manager:
		sound_manager.stop_ambience_music("space_ambience")
	
	var levels_frame = get_parent()
	
	if ui_handler:
		ui_handler.show_level_cutscene(next_level_number, func(): _show_clock_animation_then_level(next_level_number, levels_frame))
	else:
		_show_clock_animation_then_level(next_level_number, levels_frame)

func start_replay_return_animation(from_level: int, to_level: int):
	disable_lobby_functionality()
	
	if level_handler and level_handler.level_status_node:
		level_handler.level_status_node.set_hand_to_clock_position(from_level)
		level_handler.level_status_node.show_level_entry_cutscene()
	
	var animation_tween = level_handler.level_status_node.animate_hand_to_next_level(to_level)
	if animation_tween:
		await animation_tween.finished
	
	await get_tree().create_timer(0.3).timeout
	level_handler.level_status_node.hide_cutscene()
	
	var lobby_player = get_node_or_null("PlayerScene")
	if lobby_player:
		lobby_player.rotation = deg_to_rad(to_level * 30)
	else:
		if player:
			player.rotation = deg_to_rad(to_level * 30)
	
	if level_handler:
		level_handler.last_play_was_replay = false
		level_handler.last_entered_level = 0
	
	enable_lobby_functionality()
	if sound_manager:
		sound_manager.play_ambience_music("space_ambience")

func get_level_number_from_entrance(entrance_obj) -> int:
	if not entrance_obj or not entrance_obj.has_method("get") or not "object_name" in entrance_obj:
		return 0
		
	var obj_name = entrance_obj.object_name
	if obj_name.begins_with("enter_"):
		var num_str = obj_name.substr(6) 
		return int(num_str)
	return 0

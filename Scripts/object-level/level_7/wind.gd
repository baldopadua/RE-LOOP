extends object_class

# ==== Wind Logic ====

# The Wind gets stronger every time the buttefly moves or flaps its wings
# The current_state get incremented and decremented respectively when BUTTERFLY moves.

# When the wind reaches state_6 - tornado - the loop will break.

@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var level_handler = $"../CanvasLayer/LevelHandler"

@warning_ignore("unused_signal")
signal add_wind_state(direction)
signal level_7_completed


@onready var animated_sprite = $AnimatedSprite2D

var is_tornado: bool = false
var is_playing: bool = false
var player_body: Node
var player_in_area: bool = false

@onready var anim_handler = get_parent().get_node("AnimationPlayer")
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var player = get_parent().get_node("PlayerScene")

func _on_add_wind_state(direction: Variant) -> void:
	if is_tornado:
		return 
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state < max_state_threshold:
			current_state += 1
		
		# Play wind/tornado sound with increasing intensity based on state
		if sound_manager and sound_manager.sfx.has("tornado"):
			var volume_scale = 0.0
			var pitch_scale = 1.0
			
			if current_state == 2:
				volume_scale = 0.5  # Very quiet breeze
				pitch_scale = 0.8
			elif current_state == 3:
				volume_scale = 0.8  # Light wind
				pitch_scale = 0.9
			elif current_state == 4:
				volume_scale = 1.0   # Moderate wind
				pitch_scale = 1.0
			elif current_state == 5:
				volume_scale = 5.0    # Strong wind
				pitch_scale = 1.1
			elif current_state == 6:
				volume_scale = 10.0    # Full tornado
				pitch_scale = 1.2
			
			# Set volume and pitch, then play
			sound_manager.set_sfx_volume("tornado", volume_scale)
			sound_manager.set_sfx_pitch_scale("tornado", pitch_scale)
			sound_manager.play_sfx("tornado")
		
		if current_state == 2:
			animated_sprite.play("wind_2")
		elif current_state == 3:
			animated_sprite.play("wind_3")
		elif current_state == 4:
			animated_sprite.play("wind_4")
		elif current_state == 5:
			animated_sprite.play("wind_5")
		elif current_state == 6:
			animated_sprite.play("wind_6")
			is_tornado = true
			#BREAK LOOP
			if sound_manager:
				# Play all finish level SFX at once
				if sound_manager.has_method("play_finish_level_sfx"):
					sound_manager.play_finish_level_sfx()
			area_handler.show_loop_break(7)
			# If player is already in area, trigger tornado sequence
			if player_in_area and not is_playing and player_body:
				_start_tornado_sequence(player_body)
	else:
		if current_state > min_state_threshold:
			current_state -= 1
		if current_state == 1:
			animated_sprite.play_backwards("wind_1")
		elif current_state == 2:
			animated_sprite.play_backwards("wind_2")
		elif current_state == 3:
			animated_sprite.play_backwards("wind_3")
		elif current_state == 4:
			animated_sprite.play_backwards("wind_4")
		elif current_state == 5:
			animated_sprite.play_backwards("wind_5")
	print("WIND CURRENT_STATE: ", current_state)

func _on_body_entered(body) -> void:
	player_in_area = true
	player_body = body
	if is_tornado and not is_playing:
		_start_tornado_sequence(body)

func _on_body_exited(body) -> void:
	if body == player_body:
		player_in_area = false

func _start_tornado_sequence(body) -> void:
	GlobalVariables.player_stopped = true
	ui_handler.hide_game_ui_elements()
	player_body = body
	player_body.get_node("Camera2D").emit_signal("pan_to_pos", player_body.get_node("AnimatedSprite2D").global_position)
	player_body.get_node("Camera2D").emit_signal("reveal_bars")
	player_body.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	await get_tree().create_timer(1).timeout
	is_playing = true
	player_body.z_index = 2
	anim_handler.play("flow_with_tornado")
	# Play fly away tornado sound when player enters tornado
	if sound_manager and sound_manager.sfx.has("fly_away_tornado"):
		sound_manager.play_sfx("fly_away_tornado")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flow_with_tornado":
		# HIDE PLAYER AFTER RIDING THE TORNADO
		player_body.visible = false
		player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
		player.get_node("Camera2D").emit_signal("cam_orig_zoom")
		player.get_node("Camera2D").emit_signal("hide_bars")
		# NOTIFY LEVEL 7 IS COMPLETED - this will handle cutscene and next level automatically
		level_handler.complete_current_level(get_parent().get_parent())
	emit_signal("level_7_completed")


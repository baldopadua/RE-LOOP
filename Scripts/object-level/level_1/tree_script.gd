extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

# TWEENS
var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween

@onready var animated_sprite = $AnimatedSprite2D
var time_indicator: AnimatedSprite2D
var is_playing: bool = false
var player_body: Node
@onready var player =  $"../PlayerScene"
@onready var black_hole = $"../Blackhole"

# HANDLERS
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var level_handler = $"../CanvasLayer/LevelHandler"
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var anim_handler = $"../AnimationPlayer"
@onready var area_handler = $"../AreaHandler"

# POS TO FOCUS
@onready var pos_to_focus = $"../pos_to_focus"
	
func _on_body_entered(body) -> void:
	handle_body_entered(body)
	
	# CLIMB THE TREE
	if not GlobalVariables.is_looping and not is_playing:
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		ui_handler.hide_game_ui_elements()
		# STORE THE PLAYER REFERENCE
		player_body = body
		
		player_body.get_node("Camera2D").emit_signal("pan_to_pos", player_body.get_node("AnimatedSprite2D").global_position)
		player_body.get_node("Camera2D").emit_signal("reveal_bars")
		player_body.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
			
		await get_tree().create_timer(1).timeout
		
		ui_handler.set_time_indicator_fixed()
		
		# PLAY CLIMB ANIMATION ON PLAYER SPRITE
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		sound_manager.play_player_sfx("Climb")
		anim_handler.play("ClimbingAnimation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ClimbingAnimation":
		# Play jump animation on player sprite after climbing finishes
		if player_body and player_body.has_node("AnimatedSprite2D"):
			var sprite = player_body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("jump")
		
		# Play jump animation in AnimationPlayer
		anim_handler.play("JumpAnimation")
	elif anim_name == "JumpAnimation":
		
		var intro_bhole_tween : Tween = create_tween()
		intro_bhole_tween.tween_method(
			func(value):
				black_hole.get_material().set_shader_parameter("strength", value),
				0.0,
				-0.6,
				3.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		intro_bhole_tween.finished.connect(func():
			intro_bhole_tween.kill()
			var end_bhole_tween: Tween = create_tween()
			end_bhole_tween.tween_method(
				func(value):
					black_hole.get_material().set_shader_parameter("strength", value),
					-0.6,
					0.0,
					0.5
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			# DECLARE LEVEL TO BE FINISHED
		
			# NOTIFY LEVEL 1 IS COMPLETED - this will handle cutscene and next level automatically
			level_handler.complete_current_level(get_parent().get_parent())
			
			end_bhole_tween.finished.connect(func():
				end_bhole_tween.kill()
				player_body.get_node("Camera2D").emit_signal("hide_bars")
				player_body.get_node("Camera2D").emit_signal("cam_orig_zoom")
				player_body.get_node("Camera2D").emit_signal("pan_to_orig_pos")
			)
		)


func _on_add_cur_state(direction: Variant) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite.play("grow_1")
		elif current_state == 3:
			animated_sprite.play("grow_2")
		elif current_state == 4:
			animated_sprite.play("grow_3")
			# Stop
			area_handler.show_loop_break(1)
			GlobalVariables.is_looping = false
			GlobalVariables.player_stopped = true

			# FOCUS ON TREE
			ui_handler.hide_game_ui_elements()
			player.get_node("Camera2D").emit_signal("pan_to_pos", pos_to_focus.global_position)
			player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
			player.get_node("Camera2D").emit_signal("reveal_bars")

			# Play SFX using SoundManager for finish_level_sfx nodes
			if sound_manager and sound_manager.has_method("play_finish_level_sfx"):
				sound_manager.play_finish_level_sfx()

			await get_tree().create_timer(2.0).timeout
			GlobalVariables.player_stopped = false
			
			# BACK TO ORIG FOCUS
			ui_handler.show_game_ui_elements()
			player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
			player.get_node("Camera2D").emit_signal("cam_orig_zoom")
			player.get_node("Camera2D").emit_signal("hide_bars")
	else:
		if current_state == 2:
			animated_sprite.play_backwards("grow_1")
		elif current_state == 3:
			animated_sprite.play_backwards("grow_2")
		elif current_state == 4:
			animated_sprite.play_backwards("grow_3")

extends object_class

# Use signals to determine if all three keystones are in order
# If time_forwarded, the laser gets activated and shots a laser into the middle

# SIGNALS
@warning_ignore("unused_signal")
signal keystone_complete(obj, enabled)

# KEYSTONE BOOLEAN SWITCHES
var did_nicola_successfully_invented_tesla: bool = false
var did_edison_successfully_invented_bulb: bool = false
var did_franklin_successfully_invented_electricity: bool = false

# MY ANIMATED SPRITE
@onready var animated_sprite = $AnimatedSprite2D
@onready var player = $"../PlayerScene"
@onready var animation_player =$"../AnimationPlayer"
@onready var sound_manager = $"../SoundManager"
var is_loop_broken = false

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
signal level_10_completed
# ENABLE PROCEEDING IN DIFFERENT LEVEL

func _on_keystone_complete(obj_name: String, enabled: bool) -> void:
	if obj_name == "nicola_tesla":
		did_nicola_successfully_invented_tesla = enabled
	elif obj_name == "thomas_edison":
		did_edison_successfully_invented_bulb = enabled
	elif obj_name == "benjamin_franklin":
		did_franklin_successfully_invented_electricity = enabled	
	
	print("KEYSTONE SWITCHES: ", did_nicola_successfully_invented_tesla, " ", did_edison_successfully_invented_bulb, " ", did_franklin_successfully_invented_electricity)
	
	# IF ALL KEYSTONE ARE COMPLETE
	if did_nicola_successfully_invented_tesla and did_edison_successfully_invented_bulb and did_franklin_successfully_invented_electricity:
		player.set_process_input(false)
		ui_handler.hide_game_ui_elements()
		var p = player.get_node("Camera2D")
		p.emit_signal("reveal_bars")
		p.emit_signal("cam_zoom", 1.5)
		p.emit_signal("pan_to_pos", get_node("AnimatedSprite2D").global_position)
		await get_tree().create_timer(1.0).timeout
		
		# Play laser loading sound
		if sound_manager and sound_manager.sfx.has("laser_loading"):
			sound_manager.play_sfx("laser_loading")
		await get_tree().create_timer(0.5).timeout
		
		# Play laser firing sound
		if sound_manager and sound_manager.sfx.has("laser_firing"):
			sound_manager.play_sfx("laser_firing")
		
		animated_sprite.play("laser_fire")		
		animated_sprite.animation_finished.connect(func():
			# Play loop break sound
			if sound_manager and sound_manager.sfx.has("loop_break"):
				sound_manager.play_sfx("loop_break")
			# DO SOMETHING HERE
			get_parent().area_handler.show_loop_break(10)
			await get_tree().create_timer(1.0).timeout
			p.emit_signal("hide_bars")
			p.emit_signal("cam_orig_zoom")
			p.emit_signal("pan_to_orig_pos")
			player.set_process_input(true)
			GlobalVariables.player_stopped = false
			GlobalVariables.is_looping = false
			is_loop_broken = true
			ui_handler.show_game_ui_elements()
		)

func _on_body_entered(body) -> void:
	
	handle_body_entered(body)
	if is_loop_broken:
		ui_handler.hide_game_ui_elements()
		player.set_process_input(false)
		var p = player.get_node("Camera2D")
		p.emit_signal("reveal_bars")
		p.emit_signal("cam_zoom", 1.5)
		p.emit_signal("pan_to_pos", player.get_node("AnimatedSprite2D").global_position)
		
		# Play laser climbing sound
		if sound_manager and sound_manager.sfx.has("laser_climb"):
			sound_manager.play_sfx("laser_climb")
		
		animation_player.play("climbing_laser")
		player.get_node("AnimatedSprite2D").play("climb")
		await animation_player.animation_finished
		player.get_node("AnimatedSprite2D").play("idle")
		await get_tree().create_timer(0.25).timeout
		player.get_node("AnimatedSprite2D").play("jump")
		animation_player.play("jumping_from_laser")
		await animation_player.animation_finished
		get_parent().level_handler.complete_current_level(get_parent().get_parent())
		emit_signal("level_10_completed")

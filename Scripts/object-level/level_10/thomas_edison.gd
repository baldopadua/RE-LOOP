extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

# INITIALLY SET TO TRUE AS THERE ARE NO WAY TO CURRENTLY KNOW THE CURRENT AREAS OBJECTS WITHIN IT
var is_in_another_object = true
var object_that_this_is_on = "tesla_coil"
@onready var animated_sprite = $AnimatedSprite2D
@onready var laser = $"../Laser"
@onready var sound_manager = $"../SoundManager"

func _on_area_entered(area: Area2D) -> void:
	if area.object_type == GlobalVariables.object_types.NONTOOL:
		is_in_another_object = true
		object_that_this_is_on = area.object_name

func _on_area_exited(area: Area2D) -> void:
	if area.object_type == GlobalVariables.object_types.NONTOOL:
		is_in_another_object = false
		object_that_this_is_on = "none"

func _on_add_cur_state(direction: Variant) -> void:
	if object_that_this_is_on == "none":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("thom_e_skull")
				# Play bones collapse sound
				if sound_manager and sound_manager.sfx.has("bones_collapse"):
					sound_manager.play_sfx("bones_collapse")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("thom_e_skull")
				is_pickupable = false

	elif object_that_this_is_on == "lightning_cloud":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("thom_e_shocked")
				is_pickupable = true
				var lightning_cloud = $"../LightningCloud"
				lightning_cloud.get_node("AnimatedSprite2D").play("lightning_cloud")
				# Play tesla_coil + laser shock combo for Edison (pitch 1.0, 1.3)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.0)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.3)
					sound_manager.play_sfx("laser")
		else:
			if current_state == 1:
				animated_sprite.play_backwards("thom_e_shocked")
				is_pickupable = false
				var lightning_cloud = $"../LightningCloud"
				lightning_cloud.get_node("AnimatedSprite2D").play_backwards("lightning_cloud")
				# Play tesla_coil + laser shock combo for Edison (pitch 1.0, 1.3)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.0)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.3)
					sound_manager.play_sfx("laser")

	elif object_that_this_is_on == "light_bulb":
		var light_bulb = $"../LightBulb" # get LightBulb node
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("thom_e_invented")
				light_bulb.get_node("AnimatedSprite2D").play("light_bulb_flicker")
				is_pickupable = false
				# Play scientist voice
				if sound_manager and sound_manager.sfx.has("scientist2"):
					sound_manager.play_sfx("scientist2")
				laser.emit_signal("keystone_complete", object_name, true)
		else:
			if current_state == 1:
				animated_sprite.play_backwards("thom_e_invented")
				light_bulb.get_node("AnimatedSprite2D").play_backwards("light_bulb_flicker")
				is_pickupable = false
				# Play scientist voice
				if sound_manager and sound_manager.sfx.has("scientist2"):
					sound_manager.play_sfx("scientist2")
				laser.emit_signal("keystone_complete", object_name, false)

	elif object_that_this_is_on == "tesla_coil":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("thom_e_shocked")
				is_pickupable = true
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play("tesla_coil_shock")
				# Play tesla_coil + laser shock combo for Edison (pitch 1.0, 1.3)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.0)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.3)
					sound_manager.play_sfx("laser")
		else:
			if current_state == 1:
				animated_sprite.play_backwards("thom_e_shocked")
				is_pickupable = false
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play_backwards("tesla_coil_shock")
				# Play tesla_coil + laser shock combo for Edison (pitch 1.0, 1.3)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.0)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.3)
					sound_manager.play_sfx("laser")

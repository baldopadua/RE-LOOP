extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

var is_in_another_object = true
var object_that_this_is_on = "light_bulb"

@onready var animated_sprite = $AnimatedSprite2D
@onready var laser = $"../Laser"
@onready var lightning_cloud = $"../LightningCloud"
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
				animated_sprite.play("ben_f_skull")
				# Play bones collapse sound
				if sound_manager and sound_manager.sfx.has("bones_collapse"):
					sound_manager.play_sfx("bones_collapse")
				is_pickupable = true
		else:
			if current_state == 1:
				is_pickupable = false
				animated_sprite.play_backwards("ben_f_skull")

	elif object_that_this_is_on == "lightning_cloud":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("ben_f_invented")
				lightning_cloud.get_node("AnimatedSprite2D").play("lightning_rod", true)
				is_pickupable = false
				# Play old scientist voice
				if sound_manager and sound_manager.sfx.has("old_scientist"):
					sound_manager.play_sfx("old_scientist")
				laser.emit_signal("keystone_complete", object_name, true)
		else:
			if current_state == 1:
				animated_sprite.play_backwards("ben_f_invented")
				lightning_cloud.get_node("AnimatedSprite2D").play_backwards("lightning_rod")
				is_pickupable = false
				# Play old scientist voice
				if sound_manager and sound_manager.sfx.has("old_scientist"):
					sound_manager.play_sfx("old_scientist")
				laser.emit_signal("keystone_complete", object_name, false)
				
	elif object_that_this_is_on == "light_bulb":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("ben_f_skull")
				# Play bones collapse sound
				if sound_manager and sound_manager.sfx.has("bones_collapse"):
					sound_manager.play_sfx("bones_collapse")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("ben_f_skull")
				is_pickupable = false

	elif object_that_this_is_on == "tesla_coil":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 2:
				animated_sprite.play("ben_f_shocked")
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play("tesla_coil_shock")
				# Play tesla_coil + laser shock combo for Franklin (pitch 1.1, 1.4)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.1)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.4)
					sound_manager.play_sfx("laser")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("ben_f_shocked")
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play_backwards("tesla_coil_shock")
				# Play tesla_coil + laser shock combo for Franklin (pitch 1.1, 1.4)
				if sound_manager and sound_manager.sfx.has("tesla_coil"):
					sound_manager.set_sfx_pitch_scale("tesla_coil", 1.1)
					sound_manager.play_sfx("tesla_coil")
				if sound_manager and sound_manager.sfx.has("laser"):
					sound_manager.set_sfx_pitch_scale("laser", 1.4)
					sound_manager.play_sfx("laser")
				is_pickupable = false

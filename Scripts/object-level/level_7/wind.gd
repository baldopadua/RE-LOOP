extends object_class

# ==== Wind Logic ====

# The Wind gets stronger every time the buttefly moves or flaps its wings
# The current_state get incremented and decremented respectively when BUTTERFLY moves.

# When the wind reaches state_6 - tornado - the loop will break.

@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var area_handler = get_parent().get_node("AreaHandler")

@warning_ignore("unused_signal")
signal add_wind_state(direction)

@onready var animated_sprite = $AnimatedSprite2D

func _on_add_wind_state(direction: Variant) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state < max_state_threshold:
			current_state += 1
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
			#BREAK LOOP
			if sound_manager:
				if sound_manager.sfx.has("sword"):
					sound_manager.play_sfx("sword")
				# Play all finish level SFX at once
				if sound_manager.has_method("play_finish_level_sfx"):
					sound_manager.play_finish_level_sfx()
			area_handler.show_loop_break(7)
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

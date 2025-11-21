extends object_class

# ==== Flower Logic ====

# Can only be trimmed and planted on one place.
# The cobweb will stop the butterfly from reaching the flower dead, 
# The flower will wither and it cannot be eaten by the butterfly if it's not fully bloomed.

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var animated_sprite = $AnimatedSprite2D

func _on_add_cur_state(direction: Variant) -> void:
	if $"../wind".is_tornado:
		return # Freeze flower logic when tornado is reached
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite.play("flower_almost_bloom")
		elif current_state == 3:
			animated_sprite.play("flower_blooming")			
		elif current_state == 4:
			animated_sprite.play("flower_dead")
	else:
		if current_state == 1:
			animated_sprite.play_backwards("flower_no_bloom")
		if current_state == 2:
			animated_sprite.play_backwards("flower_almost_bloom")
		if current_state == 3:
			animated_sprite.play_backwards("flower_blooming")

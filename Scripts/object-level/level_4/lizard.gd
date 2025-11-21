extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var sprite = $AnimatedSprite2D
@onready var sound_manager = get_parent().get_node("SoundManager")
		
func interact(object_interacted: object_class):
	if object_interacted.object_name == "incubator" and current_state == 2:
		object_interacted.item_put.emit(self)
		print("MATERIAL COUNT: ", object_interacted.material_count)
		if object_interacted.material_count == 2:
			position = Vector2(0, 50.0)
			reparent(object_interacted)
			is_pickupable = false
			visible = false
			return true
	return false


func _on_add_cur_state(direction: Variant) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			sprite.play("Present")
			if sound_manager and sound_manager.sfx.has("lizard"):
				sound_manager.play_sfx("lizard")
				get_tree().create_timer(0.59).timeout.connect(func():
					if sound_manager.sfx["lizard"].playing:
						sound_manager.sfx["lizard"].stop()
				)
			is_pickupable = true
		elif current_state == 3:
			sprite.play("Future")
			is_pickupable = false
	else:
		if current_state == 1:
			sprite.play_backwards("Present")
			is_pickupable = false
		elif current_state == 2:
			sprite.play_backwards("Future")
			is_pickupable = true
			

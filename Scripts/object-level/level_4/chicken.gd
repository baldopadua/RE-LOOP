extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var sprite = $AnimatedSprite2D
@onready var player = $"../PlayerScene"
@onready var sound_manager = get_parent().get_node("SoundManager")
	
func interact(object_interacted: object_class):
	if object_interacted.object_name == "incubator" :
		object_interacted.item_put.emit(self)
		if object_interacted.material_count == 1:
			position = Vector2(0, 50.0)
			reparent(object_interacted)
			is_pickupable = false
			visible = false
			return true
	return false


func _on_add_cur_state(direction: Variant) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			sprite.play("chick_to_chicken")
			if sound_manager and sound_manager.sfx.has("chicken_sound"):
				sound_manager.play_sfx("chicken_sound")
			is_pickupable = false
			
		elif current_state == 3:
			sprite.play("chicken_to_feather")
			if sound_manager and sound_manager.sfx.has("egg_pop"):
				var egg_pop_sfx = sound_manager.sfx["egg_pop"]
				if not egg_pop_sfx.playing:
					sound_manager.play_sfx("egg_pop")
					egg_pop_sfx.seek(0.60)
			sprite.animation_finished.connect(func():
				is_pickupable = true
			, CONNECT_ONE_SHOT)
			
	else:
		
		if current_state == 1:
			sprite.play_backwards("chick_to_chicken")
			if sound_manager and sound_manager.sfx.has("sisiw"):
				sound_manager.play_sfx("sisiw")
			is_pickupable = false
			
		elif current_state == 2:
			sprite.play_backwards("chicken_to_feather")
			if sound_manager and sound_manager.sfx.has("chicken_sound"):
				sound_manager.play_sfx("chicken_sound")
			is_pickupable = false

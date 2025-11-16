extends object_class

# Spiders will kill the butterfly, remove them!

@onready var butterfly = $"../butterfly"
@onready var animated_sprite = $AnimatedSprite2D
@onready var player = $"../PlayerScene"
@onready var mark_to_pos = $Marker2D
@warning_ignore("unused_signal")
signal add_cur_state(direction)

func _on_area_entered(area: Area2D) -> void:
	if area == butterfly:
		# IGNORE COLLISION IF BEING HELD OR IF SPIDER IS DEAD
		if is_pickupable or current_state == 1:
			return
		# Eat the motherfucker >:)
		# Focus camera here and then restart
		butterfly.is_alive = false
		
		player.set_process_input(false)
		
		player.get_node("Camera2D").emit_signal("pan_to_pos", mark_to_pos.global_position)
		player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
		player.get_node("Camera2D").emit_signal("reveal_bars")
		
		await get_tree().create_timer(2.0).timeout  
		
		animated_sprite.play("spider_eating")
		butterfly.animated_sprite.play("eaten_butterfly")
		await animated_sprite.animation_finished
		
		player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
		player.get_node("Camera2D").emit_signal("cam_orig_zoom")
		player.get_node("Camera2D").emit_signal("hide_bars")
		
		await get_tree().create_timer(1.0).timeout
		
		player.level_handler.restart_level(get_parent().get_parent())
	# ELSE: IGNORE COLLISION IF BEING HELD OR DEAD


func _on_add_cur_state(direction: Variant) -> void:
	if not butterfly.is_alive:
		return
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite.play("default")
			is_pickupable = false
			if butterfly.get_overlapping_areas().has(self):
				_on_area_entered(butterfly)
	else:
		if current_state == 1:
			animated_sprite.play("dead_spider")
			is_pickupable = true

extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

var is_in_another_object = true
var object_that_this_is_on = "lightning_cloud"

@onready var animated_sprite = $AnimatedSprite2D
@onready var laser = $"../Laser"

func _on_area_entered(area: Area2D) -> void:
	if area.object_type == GlobalVariables.object_types.NONTOOL:
		is_in_another_object = true
		object_that_this_is_on = area.object_name

func _on_area_exited(area: Area2D) -> void:
	if area.object_type == GlobalVariables.object_types.NONTOOL:
		is_in_another_object = false
		object_that_this_is_on = "none"

func _on_add_cur_state(direction) -> void:
	if object_that_this_is_on == "none":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("nic_t_skull")
				is_pickupable = true
		else:
			if current_state == 1:
				is_pickupable = false
				animated_sprite.play_backwards("default")
			elif current_state == 2:
				animated_sprite.play_backwards("nic_t_skull")
				is_pickupable = true

	elif object_that_this_is_on == "lightning_cloud":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				var lightning_cloud = $"../LightningCloud"
				lightning_cloud.get_node("AnimatedSprite2D").play("lightning_rod")
				is_pickupable = false
				laser.emit_signal("keystone_complete", object_name, true)
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
				laser.emit_signal("keystone_complete", object_name, false)
			elif current_state == 2:
				var lightning_cloud = $"../LightningCloud"
				lightning_cloud.get_node("AnimatedSprite2D").play_backwards("lightning_rod")
				is_pickupable = false

	elif object_that_this_is_on == "light_bulb":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("nic_t_skull")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play_backwards("nic_t_skull")
				is_pickupable = true

	elif object_that_this_is_on == "tesla_coil":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play("tesla_coil_two")
				is_pickupable = false
				laser.emit_signal("keystone_complete", object_name, true)
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
				laser.emit_signal("keystone_complete", object_name, false)
			elif current_state == 2:
				var tesla_coil = $"../TeslaCoil"
				tesla_coil.get_node("AnimatedSprite2D").play_backwards("teslo_coil_two")
				is_pickupable = false

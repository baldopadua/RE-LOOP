extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

# INITIALLY SET TO TRUE AS THERE ARE NO WAY TO CURRENTLY KNOW THE CURRENT AREAS OBJECTS WITHIN IT
var is_in_another_object = true
var object_that_this_is_on = "light_bulb"
@onready var animated_sprite = $AnimatedSprite2D
@onready var laser = $"../Laser"


func _on_area_entered(area: Area2D) -> void:
	is_in_another_object = true
	object_that_this_is_on = area.object_name


func _on_area_exited(_area: Area2D) -> void:
	is_in_another_object = false
	object_that_this_is_on = "none"


func _on_add_cur_state(direction: Variant) -> void:
	if object_that_this_is_on == "none":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("ben_f_skull")
				is_pickupable = true
		else:
			if current_state == 1:
				is_pickupable = false
				animated_sprite.play_backwards("default")
			elif current_state == 2:
				animated_sprite.play_backwards("ben_f_skull")
				is_pickupable = true
	elif object_that_this_is_on == "lightning_cloud":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("ben_f_invented")
				is_pickupable = false
				# SET ONE OF LASER'S KEYSTONE TO SUCCESS
				laser.emit_signal("keystone_complete", self, true)
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
				# UNSET ONE OF LASER'S KEYSTONE TO SUCCESS
				laser.emit_signal("keystone_complete", self, false)
			elif current_state == 2:
				animated_sprite.play_backwards("ben_f_invented")
				is_pickupable = false
	elif object_that_this_is_on == "light_bulb":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("ben_f_skull")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play_backwards("ben_f_skull")
				is_pickupable = true
	elif object_that_this_is_on == "tesla_coil":
		if direction == GlobalVariables.player_direction.CLOCKWISE:
			if current_state == 1:
				animated_sprite.play("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play("ben_f_shocked")
				is_pickupable = true
		else:
			if current_state == 1:
				animated_sprite.play_backwards("default")
				is_pickupable = false
			elif current_state == 2:
				animated_sprite.play_backwards("ben_f_shocked")
				is_pickupable = true

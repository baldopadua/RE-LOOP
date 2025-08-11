extends object_class

var previous_state: int = 3
var old_man = self

func _process(delta: float) -> void:
	update_old_man_visibility()

func update_old_man_visibility():
	if not old_man:
		return
	
	var current_state = old_man.current_state
	
	if current_state == 5:
		is_pickupable = true
	else:
		is_pickupable = false
	
	if current_state != previous_state:
		print(previous_state, " ", current_state)
		match [previous_state, current_state]:
			[1, 2]:
				old_man.get_node("AnimatedSprite2D").play("young_to_strong")
			[2, 3]:
				old_man.get_node("AnimatedSprite2D").play("strong_to_old")				
			[3, 4]:
				old_man.get_node("AnimatedSprite2D").play("old_to_super_old")
			[4, 5]:
				old_man.get_node("AnimatedSprite2D").play("dead_skeleton")

			# Reverse animations
			[5, 4]:
				var sprite = old_man.get_node("AnimatedSprite2D")
				sprite.play_backwards("dead_skeleton")
				# Wait until it finishes
				await sprite.animation_finished
				sprite.play("old_to_super_old")
			[4, 3]:
				old_man.get_node("AnimatedSprite2D").play_backwards("old_to_super_old")
			[3, 2]:
				old_man.get_node("AnimatedSprite2D").play_backwards("strong_to_old")
			[2, 1]:
				old_man.get_node("AnimatedSprite2D").play_backwards("young_to_strong")
			
		previous_state = current_state

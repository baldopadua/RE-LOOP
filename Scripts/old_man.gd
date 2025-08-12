extends object_class

var previous_state: int = 3
var old_man = self

func _process(_delta: float) -> void:
	update_old_man_visibility()

func update_old_man_visibility():
	if not old_man:
		return
	
	if current_state == 5:
		is_pickupable = true
	else:
		is_pickupable = false
	
	if current_state != previous_state:
		print("PREVIOUS STATE: ", previous_state, " ", "CURRENT STATE: ", current_state)
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
				old_man.get_node("AnimatedSprite2D").play("skeleton_to_super_old")
			[4, 3]:
				old_man.get_node("AnimatedSprite2D").play_backwards("old_to_super_old")
			[3, 2]:
				old_man.get_node("AnimatedSprite2D").play_backwards("strong_to_old")
			[2, 1]:
				old_man.get_node("AnimatedSprite2D").play_backwards("young_to_strong")
			
		previous_state = current_state

func interact(object_interacted: object_class):
	if object_interacted.object_name == "sword" and current_state == 5:
		position = Vector2(0, 50.0)
		reparent(object_interacted)
		is_pickupable = false

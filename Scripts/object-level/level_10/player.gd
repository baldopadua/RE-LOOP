extends "res://Scripts/player_script.gd"

func item_drop() -> void:
	if held_object and not is_moving:
		# GET DROP POSITION - USE THE OBJECT_DROP_POSITION AS BASE
		var drop_position = object_drop_position.global_position
		
		# CHECK IF WE'RE DROPPING ON AN INTERACTABLE OBJECT (like soil)
		if interactable_objects.size() > 0:
			for interactable in interactable_objects:
				if interactable.object_type == GlobalVariables.object_types.NONTOOL:
					if held_object.has_method("interact"):
						var interaction_success = held_object.interact(interactable)
						if interaction_success:
							held_object = null
							is_holding_object = false
							interactable_objects.clear()
							sound_manager.play_sfx("pickup")
							print("Object interacted successfully")
							return
		
		# CHECK IF WE'RE STACKING ON ANOTHER OBJECT (only for pickupable tools)
		handle_normal_drop(drop_position)
		
		sound_manager.play_sfx("pickup")
		held_object = null
		is_holding_object = false
		interactable_objects.clear()
		print("Object dropped")

extends "res://Scripts/player_script.gd"



func item_pick_up() -> void:
	if not is_holding_object and available_object.is_reachable and not is_moving:
		sound_manager.play_sfx("pickup")
		
		if available_object.object_name == "switch_circle":
			# Emit signal to switch circle
			available_object.emit_signal("toggle_switch_circle")

func handle_normal_drop(_drop_position) -> void:
	if held_object:
		# UPDATE OBJECT PROPERTIES
		held_object.is_pickupable = true	
		held_object.reparent(get_parent())
		
func handle_stack_drop(target_object) -> void:
	if held_object:
		target_object.tool_stack.push_back(held_object)
		held_object.is_pickupable = true
		held_object.reparent(get_parent())
		held_object.z_index = target_object.z_index + 1
		# Ensure all objects in the stack are pickupable after drop
		for obj in target_object.tool_stack:
			obj.is_pickupable = true

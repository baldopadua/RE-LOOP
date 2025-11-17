extends "res://Scripts/player_script.gd"

@onready var turtle = $"../Turtle"
@onready var hare = $"../Hare"
@onready var marker1 = $"../marker1"
@onready var marker_gun_player = $"../player_gun_marker"
@onready var gun = $"../Gun"
@onready var chair = $"../Chair"
@onready var carrot = $"../Small Carrot"

#func _on_player_finished_moving() -> void:
	#turtle.emit_signal("rotate_object", direction)
	#hare.emit_signal("rotate_object", direction)

func item_pick_up() -> void:
	if not is_holding_object and available_object.is_reachable and not is_moving:
		var popped_object = null
		if available_object and available_object.object_type == GlobalVariables.object_types.TOOL:
			var stack_size = available_object.tool_stack.size()
			# Find all objects at the 2nd layer position
			var second_layer_indices = []
			for i in range(stack_size):
				var obj = available_object.tool_stack[i]
				if obj.global_position == object_drop_position2ndlayer.global_position:
					second_layer_indices.append(i)
			second_layer_indices.reverse()
			if second_layer_indices.size() > 0:
				# Only pick up objects at the 2nd layer if any exist
				for i in second_layer_indices:
					popped_object = available_object.tool_stack.pop_at(i)
					break
			elif stack_size > 0:
				# Only if there are no objects at the 2nd layer, pick up from the first layer
				popped_object = available_object.tool_stack.pop_back()
			# INCREASE ROTATION OF AVAIL OBJ FIRST
			available_object.position += Vector2(10,0)
			# DECREASE ROTATION OF EVERY OBJ IN STACK
			if available_object.tool_stack.size() > 0:
				for obj in available_object.tool_stack:
					obj.position += Vector2(10,0)
		
		if popped_object:
			popped_object.is_pickupable = false
			held_object = popped_object
			popped_object.reparent(object_pos)	 
			update_held_object_direction()
			print("Object picked up: " + held_object.object_name)
		elif available_object and (not available_object.object_type == GlobalVariables.object_types.TOOL or available_object.tool_stack.size() < 1):
			available_object.is_pickupable = false
			held_object = available_object
			available_object.reparent(object_pos)	 
			update_held_object_direction()
			print("Object picked up: " + held_object.object_name)
		else:
			return
		
		# TWEEN TO ADD BOUNCE WHEN PICKING UP
		var tween_pickup = create_tween()
		var screen_center = Vector2.ZERO   
		tween_pickup.tween_property(held_object, "position", screen_center, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween_pickup.finished
		tween_pickup.kill()
		
		sound_manager.play_sfx("pickup")
		# The player is currently holding an object
		is_holding_object = true
		
		if held_object.object_name == "gun":
			set_process_input(false)
			camera2d.emit_signal("pan_to_pos", marker_gun_player.global_position)
			camera2d.emit_signal("cam_zoom", 1.5)
			camera2d.emit_signal("reveal_bars")
			
			await get_tree().create_timer(2.0).timeout  
			held_object.animated_sprite.play("fire")
			
			await get_tree().create_timer(1.5).timeout  
			held_object.animated_sprite.play("default")
				
			camera2d.emit_signal("pan_to_pos", marker1.global_position)
			camera2d.emit_signal("cam_zoom", 1.2)
			
			await get_tree().create_timer(2.0).timeout  
			held_object.emit_signal("start_race")
			
			await held_object.race_finished
			
			camera2d.emit_signal("pan_to_orig_pos")
			camera2d.emit_signal("cam_orig_zoom")
			camera2d.emit_signal("hide_bars")
			
			if held_object.turtle_won:
				# Hare cutscene
				# Hare throws child and break loop
				# enable body area of hare
				# disable loop
				item_drop()	
				gun.is_pickupable = false
				carrot.is_pickupable = false
				chair.is_pickupable = false
				GlobalVariables.player_stopped = false
				set_process_input(true)
			else:
				# Show turtle is crying and rabbit is celebrating
				await get_tree().create_timer(2.0).timeout
				level_handler.restart_level(get_parent().get_parent())	

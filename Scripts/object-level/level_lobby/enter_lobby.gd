extends Node

static var level_titles = {
	1: "Level 1: The Ancient Tree",
	2: "Level 2: The Old Man", 
	3: "Level 3: Under Pressure",
	4: "Level 4: The Theory of Evolution",
	5: "Level 5: Rocket Science",
	6: "Level 6: Gravity of the Situation",
	7: "Level 7: The Butterfly Effect",  
	8: "Level 8: The Turtle and The Hare", 
	9: "Level 9: Schrödinger's Cat",  
	10: "Level 10: Shock Therapy",
	11: "Level 11: The Sanctuary",
	12: "Level 12: Plooy"  
}

# HANDLE LEVEL ENTRANCE FOR ANY LEVEL (1-12)
static func handle_level_entrance(level_number: int, object_interacted: object_class):
	print("enter_", level_number, " interact called with: ", object_interacted.object_name)
	
	# --- NEW: handle enter_13 as "done with level 12" ---
	if object_interacted.object_name == "enter_13":
		var parent_scene = object_interacted.get_parent()
		while parent_scene and not parent_scene.has_method("enter_level") and not parent_scene.has_method("handle_enter_13_interaction"):
			parent_scene = parent_scene.get_parent()
		# Always mark level 12 as complete
		var level_handler = object_interacted.get_level_handler()
		if level_handler and not level_handler.completed_levels.has(12):
			level_handler.completed_levels.append(12)
			print("Level 12 marked as completed via enter_13 (from enter_lobby.gd).")
			if level_handler.level_status_node and level_handler.level_status_node.has_method("update_completed_levels_visual"):
				level_handler.level_status_node.update_completed_levels_visual(level_handler.completed_levels)
		# If in level_lobby, call handle_enter_13_interaction (already handled)
		if parent_scene and parent_scene.has_method("handle_enter_13_interaction"):
			parent_scene.handle_enter_13_interaction()
			return
		# If in level_12_scene, play comic cutscene then return to lobby
		if parent_scene and parent_scene.name == "level_12_scene":
			if level_handler and level_handler.ui_handler:
				# Show comic cutscene, then return to lobby
				level_handler.ui_handler.show_level_cutscene(12, func(): level_handler.return_to_lobby(parent_scene.get_parent()))
			else:
				# Fallback: just return to lobby
				level_handler.return_to_lobby(parent_scene.get_parent())
			return
		return
	
	if object_interacted.object_name == "enter_" + str(level_number):
		if object_interacted.hover_text_label:
			object_interacted.hover_text_label.visible = false
		
		var current_level_scene = _get_current_level_scene(object_interacted)
		if current_level_scene:
			print("Detected we're in level scene: ", current_level_scene.name)
			
			var scene_level_handler = object_interacted.get_level_handler()
			if scene_level_handler:
				var levels_frame = current_level_scene.get_parent()
				scene_level_handler.complete_current_level(levels_frame)
			else:
				if current_level_scene.has_method("enter_level"):
					current_level_scene.enter_level()
			return
		
		var level_handler = object_interacted.get_level_handler()
		if level_handler and not object_interacted.is_level_accessible(level_number, level_handler):
			object_interacted.show_interact_text("LOCKED")
			await object_interacted.get_tree().create_timer(1.5).timeout
			object_interacted.hide_text()
			return
		
		var lobby_scene = object_interacted.get_parent()
		while lobby_scene and (not lobby_scene.has_method("enter_level") or lobby_scene.name == "level_status"):
			lobby_scene = lobby_scene.get_parent()
		if lobby_scene and lobby_scene.name == "level_status":
			print("Found parent is level_status, not calling enter_level.")
			return
		if lobby_scene:
			print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
			await object_interacted.get_tree().create_timer(0.3).timeout
			
			var method_info = _get_method_info(lobby_scene, "enter_level")
			if method_info and method_info.args.size() > 0:
				print("Calling parent scene's enter_level WITH level_number parameter: ", level_number)
				lobby_scene.enter_level(level_number)
			else:
				print("Calling parent scene's enter_level with NO parameters")
				lobby_scene.enter_level()
		else:
			print("No parent with enter_level method found!")

# GET METHOD INFORMATION
static func _get_method_info(object_ref, method_name: String):
	if object_ref and object_ref.has_method("get_method_list"):
		var methods = object_ref.get_method_list()
		for method in methods:
			if method.name == method_name:
				return method
	return null

# DETECT IF WE'RE IN A LEVEL SCENE
static func _get_current_level_scene(object_ref: object_class) -> Node:
	var current = object_ref.get_parent()
	while current != null:
		if current.has_method("enter_level") and current.name.contains("level_") and not current.name.contains("lobby"):
			return current
		current = current.get_parent()
	return null

# HANDLE HOVER BEHAVIOR FOR ANY LEVEL
static func handle_level_hover(level_number: int, object_ref: object_class):
	if object_ref.get_parent() and object_ref.get_parent().name == "level_status":
		return
	print("Handle level hover called for level: ", level_number, " object: ", object_ref.object_name)
	
	var level_handler = object_ref.get_level_handler()
	print("Level handler found: ", level_handler != null)
	
	if level_handler:
		var is_accessible = object_ref.is_level_accessible(level_number, level_handler)
		print("Level ", level_number, " is accessible: ", is_accessible)
		
		if is_accessible:
			if level_titles.has(level_number):
				var title = level_titles[level_number]
				print("Showing hover text: ", title)
				object_ref.show_hover_text(title)
			else:
				print("No title found for level: ", level_number)
		else:
			print("Level not accessible, showing LOCKED")
			object_ref.show_interact_text("LOCKED")
	else:
		print("No level handler found")

# HANDLE HOVER EXIT FOR ANY LEVEL
static func handle_level_hover_exit(object_ref: object_class):
	if object_ref.get_parent() and object_ref.get_parent().name == "level_status":
		return
	print("Handle level hover exit called for: ", object_ref.object_name)
	object_ref.hide_text()

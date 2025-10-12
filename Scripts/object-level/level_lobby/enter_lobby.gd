extends Node

# Level titles mapping
static var level_titles = {
	1: "Level 1: Ancient Tree",
	2: "Level 2: Old Man", 
	3: "Level 3: Under Pressure",
	4: "Level 4: The Theory of Evolution",
	5: "Level 5: Rocket Science",
	6: "Level 6: Variance",
	7: "Level 7",  
	8: "Level 8", 
	9: "Level 9",  
	10: "Level 10",
	11: "Level 11",
	12: "Level 12"  
}

# GENERAL FUNCTION TO HANDLE LEVEL ENTRANCE FOR ANY LEVEL (1-12)
static func handle_level_entrance(level_number: int, object_interacted: object_class):
	print("enter_", level_number, " interact called with: ", object_interacted.object_name)
	
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
		
		# CHECK IF LEVEL IS ACCESSIBLE BEFORE ENTERING (LOBBY BEHAVIOR)
		var level_handler = object_interacted.get_level_handler()
		if level_handler and not object_interacted.is_level_accessible(level_number, level_handler):
			object_interacted.show_interact_text("LOCKED")
			await object_interacted.get_tree().create_timer(1.5).timeout
			object_interacted.hide_text()
			return
		
		# GET THE LOBBY SCENE (PARENT OF THIS OBJECT)
		var lobby_scene = object_interacted.get_parent()
		print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
		await object_interacted.get_tree().create_timer(0.3).timeout
		
		# TRIGGER LEVEL SELECTION - LOBBY SCENE ENTER_LEVEL DOES TAKE THE LEVEL_NUMBER PARAMETER
		if lobby_scene.has_method("enter_level"):
			var method_info = _get_method_info(lobby_scene, "enter_level")
			if method_info and method_info.args.size() > 0:
				print("Calling parent scene's enter_level WITH level_number parameter: ", level_number)
				lobby_scene.enter_level(level_number)
			else:
				print("Calling parent scene's enter_level with NO parameters")
				lobby_scene.enter_level()
		else:
			print("lobby_scene doesn't have enter_level method")

# HELPER FUNCTION TO GET METHOD INFORMATION
static func _get_method_info(object_ref, method_name: String):
	if object_ref and object_ref.has_method("get_method_list"):
		var methods = object_ref.get_method_list()
		for method in methods:
			if method.name == method_name:
				return method
	return null

# HELPER FUNCTION TO DETECT IF WE'RE IN A LEVEL SCENE
static func _get_current_level_scene(object_ref: object_class) -> Node:
	var current = object_ref.get_parent()
	while current != null:
		if current.has_method("enter_level") and current.name.contains("level_") and not current.name.contains("lobby"):
			return current
		current = current.get_parent()
	return null

# GENERAL FUNCTION TO HANDLE HOVER BEHAVIOR FOR ANY LEVEL
static func handle_level_hover(level_number: int, object_ref: object_class):
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
			print("Level not accessible, not showing hover")
	else:
		print("No level handler found")

# GENERAL FUNCTION TO HANDLE HOVER EXIT FOR ANY LEVEL
static func handle_level_hover_exit(object_ref: object_class):
	print("Handle level hover exit called for: ", object_ref.object_name)
	object_ref.hide_text()

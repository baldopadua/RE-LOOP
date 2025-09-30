extends Node

# Level titles mapping
static var level_titles = {
	1: "Level 1: Ancient Tree",
	2: "Level 2: Old Man", 
	3: "Level 3: Under Pressure",
	4: "Level 4: The Theory of Evolution",
	5: "Level 5: Rocket Science",
	6: "Level 6: Variance",
	7: "Level 7",  # Placeholder until decided
	8: "Level 8",  # Placeholder until decided
	9: "Level 9",  # Placeholder until decided
	10: "Level 10", # Placeholder until decided
	11: "Level 11", # Placeholder until decided
	12: "Level 12"  # Placeholder until decided
}

# General function to handle level entrance for any level (1-12)
static func handle_level_entrance(level_number: int, object_interacted: object_class):
	print("enter_", level_number, " interact called with: ", object_interacted.object_name)
	
	if object_interacted.object_name == "enter_" + str(level_number):
		# Hide hover text immediately when interacting
		if object_interacted.hover_text_label:
			object_interacted.hover_text_label.visible = false
		
		# Check if level is accessible before entering
		var level_handler = object_interacted.get_level_handler()
		if level_handler and not object_interacted.is_level_accessible(level_number, level_handler):
			object_interacted.show_interact_text("LOCKED")
			await object_interacted.get_tree().create_timer(1.5).timeout
			object_interacted.hide_text()
			return
		
		# Get the lobby scene (parent of this object)
		var lobby_scene = object_interacted.get_parent()
		print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
		
		# Small delay for interaction feedback
		await object_interacted.get_tree().create_timer(0.3).timeout
		
		# Trigger level selection
		if lobby_scene.has_method("enter_level"):
			lobby_scene.enter_level(level_number)
		else:
			print("lobby_scene doesn't have enter_level method")

# General function to handle hover behavior for any level
static func handle_level_hover(level_number: int, object_ref: object_class):
	print("Handle level hover called for level: ", level_number, " object: ", object_ref.object_name)
	
	# Check if level is accessible before showing hover
	var level_handler = object_ref.get_level_handler()
	print("Level handler found: ", level_handler != null)
	
	if level_handler:
		var is_accessible = object_ref.is_level_accessible(level_number, level_handler)
		print("Level ", level_number, " is accessible: ", is_accessible)
		
		if is_accessible:
			# Set the hover text to the level title and show it
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

# General function to handle hover exit for any level
static func handle_level_hover_exit(object_ref: object_class):
	print("Handle level hover exit called for: ", object_ref.object_name)
	object_ref.hide_text()

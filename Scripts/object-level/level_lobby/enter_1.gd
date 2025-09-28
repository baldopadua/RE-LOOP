extends object_class 


func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)
	# Text hiding is now handled in the base class setup_text_label()

# Override hover behavior - show level name
func on_hover_enter():
	print("on_hover_enter called for enter_1")
	show_text("Enter Level 1: Ancient Tree")


func interact(object_interacted: object_class):
	print("enter_1 interact called with: ", object_interacted.object_name)
	if object_interacted.object_name == "enter_1":
		# Check if level is accessible before entering
		var level_handler = get_level_handler()
		if level_handler and not is_level_accessible(1, level_handler):
			show_text("LOCKED")
			await get_tree().create_timer(1.0).timeout
			hide_text()
			return
		
		# Get the lobby scene (parent of this object)
		var lobby_scene = get_parent()
		print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
		
		# Small delay for interaction feedback
		await get_tree().create_timer(0.3).timeout
		
		# Trigger level 1 selection
		if lobby_scene.has_method("enter_level"):
			lobby_scene.enter_level(1)
		else:
			print("lobby_scene doesn't have enter_level method")
		if lobby_scene.has_method("enter_level"):
			lobby_scene.enter_level(1)
		else:
			print("lobby_scene doesn't have enter_level method")
		

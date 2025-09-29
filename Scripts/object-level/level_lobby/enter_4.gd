extends object_class


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)
	# Text hiding is now handled in the base class setup_text_label()

# Override hover behavior - show level name only if accessible
func on_hover_enter():
	# Check if level is accessible before showing hover
	var level_handler = get_level_handler()
	if level_handler and is_level_accessible(4, level_handler):
		show_hover_text()

func interact(object_interacted: object_class):
	print("enter_4 interact called with: ", object_interacted.object_name)
	if object_interacted.object_name == "enter_4":
		# Hide hover text immediately when interacting
		if hover_text_label:
			hover_text_label.visible = false
		
		# Check if level is accessible before entering
		var level_handler = get_level_handler()
		if level_handler and not is_level_accessible(4, level_handler):
			show_interact_text("LOCKED")
			await get_tree().create_timer(1.5).timeout
			hide_text()
			return
		
		# Get the lobby scene (parent of this object)
		var lobby_scene = get_parent()
		print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
		
		# Small delay for interaction feedback
		await get_tree().create_timer(0.3).timeout
		
		# Trigger level 4 selection
		if lobby_scene.has_method("enter_level"):
			lobby_scene.enter_level(4)
		else:
			print("lobby_scene doesn't have enter_level method")

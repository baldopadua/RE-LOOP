extends object_class


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)





func interact(object_interacted: object_class):
	print("enter_3 interact called with: ", object_interacted.object_name)
	if object_interacted.object_name == "enter_3":
		# Get the lobby scene (parent of this object)
		var lobby_scene = get_parent()
		print("lobby_scene found: ", lobby_scene.name, " - has enter_level method: ", lobby_scene.has_method("enter_level"))
		
		# Small delay for interaction feedback
		await get_tree().create_timer(0.3).timeout
		
		# Trigger level 3 selection
		if lobby_scene.has_method("enter_level"):
			lobby_scene.enter_level(3)
		else:
			print("lobby_scene doesn't have enter_level method")

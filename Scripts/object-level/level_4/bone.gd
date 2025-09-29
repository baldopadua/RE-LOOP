extends object_class

func interact(interactable_obj):
	if interactable_obj.name == "incubator":
		position = Vector2(0, 50.0)
		reparent(interactable_obj)
		is_pickupable = false
		visible = false
		interactable_obj.item_put.emit(self)
		
		# Stop the player
		# Play incubator processing
		

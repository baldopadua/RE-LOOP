extends object_class

func interact(object_interacted):
	# Item Put signal will return true if this object is in valid order
	if object_interacted.name == "incubator":
		object_interacted.item_put.emit(self)
		if object_interacted.material_count == 3:
			position = Vector2(0, 50.0)
			reparent(object_interacted)
			is_pickupable = false
			visible = false
			return true
	return false
		
		# Stop the player
		# Play incubator processing
		

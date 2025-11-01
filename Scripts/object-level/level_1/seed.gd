extends object_class

func interact(object_interacted: object_class):
	if object_interacted.object_name == "soil":
		position = Vector2(0, 100.0)
		reparent(object_interacted)
		is_pickupable = false
		return true
	return false

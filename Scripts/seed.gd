extends object_class

func interact(object_interacted: object_class):
	if object_interacted.object_name == "soil":
		reparent(object_interacted)
		is_pickupable = false

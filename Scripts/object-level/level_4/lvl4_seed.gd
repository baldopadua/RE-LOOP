extends object_class

@onready var stick = $"../stick"

func interact(object_interacted: object_class):
	if object_interacted.object_name == "lvl4_soil":
		position = Vector2(0, 50.0)
		reparent(object_interacted)
		is_pickupable = false
		visible = false
		stick.visible = true
		return true
	return false

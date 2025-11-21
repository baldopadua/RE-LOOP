extends object_class

@onready var stick = $"../stick"
@onready var sound_manager = get_parent().get_node("SoundManager")

func interact(object_interacted: object_class):
	if object_interacted.object_name == "lvl4_soil":
		if sound_manager and sound_manager.sfx.has("tanim_seed"):
					sound_manager.play_sfx("tanim_seed")
		position = Vector2(0, 50.0)
		reparent(object_interacted)
		is_pickupable = false
		visible = false
		stick.visible = true
		return true
	return false

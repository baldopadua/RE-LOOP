extends object_class

var area_entered_objects : Array = []
@onready var sound_manager = get_parent().get_node("SoundManager")

func _on_body_entered(body) -> void:
	handle_body_entered(body)
	# Play soda pop sound when player picks it up
	if body.name == "PlayerScene" and is_pickupable:
		if sound_manager and sound_manager.sfx.has("soda_pop"):
			sound_manager.play_sfx("soda_pop")

func interact(_obj):
	return false

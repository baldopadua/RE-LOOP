extends object_class

@onready var animated_sprite2 = $AnimatedSprite2D2
var matched = false

func _on_is_dropped(plooy_rotation: Variant) -> void:
	if round(position) == Vector2(125.0, 199.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false

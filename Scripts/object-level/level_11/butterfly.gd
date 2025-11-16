extends object_class
var matched = false
@onready var animated_sprite2 = $AnimatedSprite2D2
func _on_is_dropped(plooy_rotation: Variant) -> void:
	if round(position) == Vector2(-115.0, 199.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false

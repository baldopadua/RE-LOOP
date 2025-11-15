extends object_class

signal add_cur_state(direction)

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite2 = $AnimatedSprite2D2
var matched = false

func _on_add_cur_state(direction: Variant) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			is_pickupable = false
			animated_sprite.play("sapling")
			animated_sprite2.play("sapling")
		elif current_state == 3:
			animated_sprite.play("semi_tree")
			animated_sprite2.play("semi_tree")
		elif current_state == 4:
			animated_sprite.play("tree")
			animated_sprite2.play("tree")
	else:
		if current_state == 1:
			is_pickupable = true
			animated_sprite.play_backwards("default")
			animated_sprite2.play_backwards("default")
		elif current_state == 2:
			animated_sprite.play_backwards("sapling")
			animated_sprite2.play_backwards("sapling")
		elif current_state == 3:
			animated_sprite.play_backwards("semi_tree")
			animated_sprite2.play_backwards("semi_tree")

func _on_is_dropped(plooy_rotation: Variant) -> void:
	print("POSITION: ", round(position))
	if plooy_rotation == 180.0 and round(position) == Vector2(240.0, 230.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false

extends object_class

signal add_cur_state(direction)

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite2 = $AnimatedSprite2D2
@onready var collision_shape = $CollisionShape2D

var matched = true
var is_loop_shown = false

func _on_add_cur_state(direction: Variant) -> void:
	if is_loop_shown:
		return

	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite.play("default")
			animated_sprite2.play("default")
		elif current_state == 3:
			animated_sprite.play("old")
			animated_sprite2.play("old")
		elif current_state == 4:
			animated_sprite.play("dead")
			animated_sprite2.play("dead")
			is_pickupable = true
	else:
		if current_state == 1:
			animated_sprite.play_backwards("young")
			animated_sprite2.play_backwards("young")
		elif current_state == 2:
			animated_sprite.play_backwards("default")
			animated_sprite2.play_backwards("default")
		elif current_state == 3:
			animated_sprite.play_backwards("old")
			animated_sprite2.play_backwards("old")
			is_pickupable = false
# If object is in the right place it will pulse green, else red
# -240, 298

func _on_is_dropped(plooy_rotation: Variant) -> void:
	print("POSITION: ", round(position))
	if plooy_rotation == 180.0 and round(position) == Vector2(240.0, 230.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false

func disable_collision():
	collision_shape.disabled = true

func enable_collision():
	collision_shape.disabled = false

func stop_animations():
	animated_sprite.stop()
	animated_sprite2.stop()

func _on_player_scene_loop_break_shown() -> void:
	is_loop_shown = true 

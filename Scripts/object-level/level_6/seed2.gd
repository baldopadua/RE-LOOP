extends object_class

signal add_cur_state(direction)

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite2 = $AnimatedSprite2D2
@onready var collision_shape = $CollisionShape2D
@onready var sound_manager = get_parent().get_node("SoundManager")

var matched = true
var is_loop_shown = false 

func _on_add_cur_state(direction: Variant) -> void:
	if is_loop_shown:
		return
	# Only allow pickup in state 1, unless matched
	if current_state == 1 and not matched:
		is_pickupable = true
	else:
		is_pickupable = false
	
	# Play leaves sound when tree/seed changes state
	if sound_manager and sound_manager.sfx.has("leaves"):
		sound_manager.play_sfx("leaves")

	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
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
	if plooy_rotation == 180.0 and round(position) == Vector2(-240.0, 230.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false

func disable_collision():
	collision_shape.disabled = true

func enable_collision():
	collision_shape.disabled = false



func _on_player_scene_loop_break_shown() -> void:
	is_loop_shown = true 

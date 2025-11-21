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
	
	# Set pitch based on current state (age)
	var pitch_scale = 1.0
	if current_state == 1:  # Young
		pitch_scale = 1.3
	elif current_state == 2:  # Default/Adult
		pitch_scale = 1.0
	elif current_state == 3:  # Old
		pitch_scale = 0.8

	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite.play("default")
			animated_sprite2.play("default")
			# Play person1 with adjusted pitch
			if sound_manager and sound_manager.sfx.has("person1"):
				sound_manager.set_sfx_pitch_scale("person1", pitch_scale)
				sound_manager.play_sfx("person1")
		elif current_state == 3:
			animated_sprite.play("old")
			animated_sprite2.play("old")
			# Play person1 with adjusted pitch
			if sound_manager and sound_manager.sfx.has("person1"):
				sound_manager.set_sfx_pitch_scale("person1", pitch_scale)
				sound_manager.play_sfx("person1")
		elif current_state == 4:
			animated_sprite.play("dead")
			animated_sprite2.play("dead")
			is_pickupable = true
			# Play bones collapse when becoming dead
			if sound_manager and sound_manager.sfx.has("bones_collapse"):
				sound_manager.play_sfx("bones_collapse")
	else:
		if current_state == 1:
			animated_sprite.play_backwards("young")
			animated_sprite2.play_backwards("young")
			# Play person1 with adjusted pitch
			if sound_manager and sound_manager.sfx.has("person1"):
				sound_manager.set_sfx_pitch_scale("person1", pitch_scale)
				sound_manager.play_sfx("person1")
		elif current_state == 2:
			animated_sprite.play_backwards("default")
			animated_sprite2.play_backwards("default")
			# Play person1 with adjusted pitch
			if sound_manager and sound_manager.sfx.has("person1"):
				sound_manager.set_sfx_pitch_scale("person1", pitch_scale)
				sound_manager.play_sfx("person1")
		elif current_state == 3:
			animated_sprite.play_backwards("old")
			animated_sprite2.play_backwards("old")
			is_pickupable = false
			# Play person1 with adjusted pitch
			if sound_manager and sound_manager.sfx.has("person1"):
				sound_manager.set_sfx_pitch_scale("person1", pitch_scale)
				sound_manager.play_sfx("person1")
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

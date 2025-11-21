extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var animated_sprite1 = $AnimatedSprite2D
@onready var animated_sprite2 = $AnimatedSprite2D2
@onready var sound_manager = $"../SoundManager"

var matched = false

var is_loop_shown = false

func _on_add_cur_state(direction: Variant) -> void:

	if is_loop_shown:
		return

	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite1.play("default")
			animated_sprite2.play("default")
			is_pickupable = true
			# Play bones collapse sound when becoming bones
			if sound_manager and sound_manager.sfx.has("bones_collapse"):
				sound_manager.play_sfx("bones_collapse")

	else:
		if current_state == 1:
			animated_sprite1.play_backwards("default")
			animated_sprite2.play_backwards("default")
			is_pickupable = false
			# Play Schrödinger voice (alive state)
			if sound_manager and sound_manager.sfx.has("schrodinger_voice"):
				sound_manager.play_sfx("schrodinger_voice")
# -355.0, 199.0
func _on_is_dropped(plooy_rotation: Variant) -> void:
	print("POSITION: ", round(position))
	#print("PLOOY ROTATION: ", plooy_rotation)
	if round(position) == Vector2(-355.0, 199.0):
		pulse("green", animated_sprite2)
		matched = true
	else:
		pulse("red", animated_sprite2)
		matched = false


func _on_player_scene_loop_break_shown() -> void:
	is_loop_shown = true

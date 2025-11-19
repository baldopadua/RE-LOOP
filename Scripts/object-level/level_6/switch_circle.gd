extends object_class

signal toggle_switch_circle()

@onready var player = $"../PlayerScene"
@onready var canvas_layer = $"../CanvasLayer"
@onready var sound_manager = $"../SoundManager"

func _on_body_entered(body) -> void:
	print("BODY ENTERED: ", get_rid())
	handle_body_entered(body)
	body.rift_near_player = true
	body.current_rift = self
	
func _on_body_exited(body) -> void:
	print("BODY EXITED: ", get_rid())
	handle_body_exited(body)
	if body.current_rift.get_rid() == get_rid():
		print("THEY ARE EQUAL")
		body.current_rift = null
		body.rift_near_player = false

func _on_toggle_switch_circle() -> void:
	if player.position.x == -240.0:
		# Play teleportation SFX
		if sound_manager and sound_manager.sfx.has("teleport"):
			sound_manager.play_sfx("teleport")
		
		var flash = ColorRect.new()
		flash.color = Color(0, 0, 0, 1)
		flash.anchor_right = 1
		flash.anchor_bottom = 1
		canvas_layer.add_child(flash)

		player.position.x = 240.0
		player.rotation_degrees = player.rotation_degrees + 180.0

		# Fade out animation
		flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	else:
		# Play teleportation SFX
		if sound_manager and sound_manager.sfx.has("teleport"):
			sound_manager.play_sfx("teleport")
		
		var flash = ColorRect.new()
		flash.color = Color(0, 0, 0, 1)
		flash.anchor_right = 1
		flash.anchor_bottom = 1
		canvas_layer.add_child(flash)

		player.position.x = -240.0
		player.rotation_degrees = player.rotation_degrees - 180.0

		# Fade out animation
		flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))

# Slow down and Brief Stop
func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1

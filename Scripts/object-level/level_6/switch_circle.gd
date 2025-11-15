extends object_class

signal toggle_switch_circle()

@onready var player = $"../PlayerScene"
@onready var canvas_layer = $"../CanvasLayer"

func _on_body_entered(body) -> void:
	handle_body_entered(body)
	emit_signal("toggle_switch_circle")

func _on_toggle_switch_circle() -> void:
	if player.position.x == -240.0:
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

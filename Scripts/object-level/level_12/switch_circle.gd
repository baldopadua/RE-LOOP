extends object_class

signal toggle_switch_circle()

@onready var player = $"../../PlayerScene"
@onready var canvas_layer = $"../../CanvasLayer"
@export var x_pos : float = 0.0
@export var y_pos : float = 0.0

func _on_body_entered(body) -> void:
	#print("BODY ENTERED: ", get_rid())
	handle_body_entered(body)
	body.rift_near_player = true
	body.current_rift = self
	
func _on_body_exited(body) -> void:
	#print("BODY EXITED: ", get_rid())
	handle_body_exited(body)
	if body.current_rift == self:
		print("THEY ARE EQUAL")
		body.current_rift = null
		body.rift_near_player = false

func _on_toggle_switch_circle() -> void:
	print("TOGGLE_SWITCH_CIRCLE TOGGLED")

	var flash = ColorRect.new()
	flash.color = Color(0, 0, 0, 1)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)

	player.position = Vector2(x_pos, y_pos)
	player.rotation_degrees += 180.0

	# Fade the flash out
	flash.create_tween() \
		.tween_property(flash, "modulate:a", 0.0, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT) \
		.finished.connect(func():canvas_layer.remove_child(flash))

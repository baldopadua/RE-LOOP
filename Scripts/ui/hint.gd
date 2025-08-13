extends Control

const OVERLAY_FINAL_SCALE = Vector2(1, 1)
const OVERLAY_START_SCALE = Vector2(0.2, 0.2)

@onready var hint_overlay := $hint_overlay
@onready var close_button := $close_button
@onready var page_turn_sound := $hint_overlay/page_turn_sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))
	close_button.z_index = 100
	hint_overlay.z_index = 99
	# Start hidden until show_hint_overlay is called
	hint_overlay.visible = false

func show_hint_overlay():
	visible = true # Ensure the root node is visible
	_reset_overlay()

func _reset_overlay():
	hint_overlay.visible = true
	hint_overlay.scale = OVERLAY_FINAL_SCALE
	var parent_size = get_viewport_rect().size
	var overlay_size = hint_overlay.size
	var final_pos = (parent_size / 2) - (overlay_size / 2)
	var start_pos = Vector2(-overlay_size.x, final_pos.y)
	hint_overlay.position = start_pos
	var tween = create_tween()
	tween.tween_property(hint_overlay, "position", final_pos, 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out_and_close()


func _fade_out_and_close():
	var parent_size = get_viewport_rect().size
	var overlay_size = hint_overlay.size
	var end_pos = Vector2(-overlay_size.x, (parent_size.y / 2) - (overlay_size.y / 2)) # to left
	var tween = create_tween()
	tween.tween_property(hint_overlay, "position", end_pos, 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_fade_out_done"))


func _on_fade_out_done():
	hint_overlay.visible = false
	visible = false # Hide the root node instead of freeing
	# queue_free() # Remove this line if you want to reuse the node

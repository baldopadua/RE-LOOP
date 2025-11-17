extends object_class

@warning_ignore("unused_signal")
signal close_box(cat)
signal open_box # New signal

@onready var cat = $"../cat"
@onready var cat2 = $"../cat2"
@onready var player = $"../PlayerScene"

var cat_placed = false
var cat2_placed = false
var box_closed = false

@onready var animation_sprite = $AnimatedSprite2D
var float_tween : Tween

func _ready() -> void:
	float_box()
	
func float_box() -> void:
	float_tween = create_tween()
	float_tween.set_loops()
	var float_offset := -5.0
	var duration := 1.0
	float_tween.tween_property(self, "position:y", self.position.y + float_offset, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	float_tween.tween_property(self, "position:y", self.position.y, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_close_box(cat_arg: Variant) -> void:
	if cat_arg.object_name == "cat":
		cat_placed = true
	elif cat_arg.object_name == "cat2":
		cat2_placed = true
	
	if cat_placed and cat2_placed:
		# Camera animations
		if cat.current_state == cat2.current_state:
			# play box close function
			close_box_function()
			

func close_box_function():
	player.set_process_input(false)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
	
	await get_tree().create_timer(1.5).timeout
	
	animation_sprite.play("activate")

	await get_tree().create_timer(1.5).timeout

	cat.visible = false
	cat2.visible = false

	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.set_process_input(true)
	box_closed = true

func open_box_function():
	player.set_process_input(false)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
	
	await get_tree().create_timer(1.0).timeout
	
	animation_sprite.play_backwards("activate")
	
	# Show the cat at frame 2
	cat.visible = true
	cat.get_node("AnimatedSprite2D").frame = 2

func _on_open_box_animation_finished(anim_name: StringName) -> void:
	if anim_name == "activate":
		player.get_node("Camera2D").emit_signal("cam_origEEEEE_zoom")
		player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
		player.set_process_input(true)
		box_closed = false
		emit_signal("open_box")
		
		visible = true

		
		if float_tween and float_tween.is_valid():
			float_tween.kill()
			print("Stopped floating tween.")

		var marker = get_parent().get_node("box_down_marker")
		print("Tweening box from ", position, " to ", marker.position)
		var tween := create_tween()
		tween.tween_property(self, "position", marker.position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.connect("finished", Callable(self, "_on_box_tween_finished"))
		print("Started downward tween.")

func _on_box_tween_finished():
	print("Box tween finished, new position: ", position)


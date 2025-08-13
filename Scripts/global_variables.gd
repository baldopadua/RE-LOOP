extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions
enum object_types {TOOL, NONTOOL}

const transition_time: float = 0.25
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false
var custom_cursor = preload("res://Assets/Loopling.png")
var plooy_right = preload("res://Assets/ui/plooy_right.png")
var plooy_left = preload("res://Assets/ui/plooy_left.png")

var custom_cursor_enabled := true

func _ready():
	# TODO: SET THE TEXTURE > FILTER OF BOTH PLOY'S RIGHT AND LEFT TO "NEAREST"
	set_custom_cursor()

func set_custom_cursor(direction = null):
	if not custom_cursor_enabled:
		return
	var cursor_texture: Texture2D = custom_cursor
	if direction == player_direction.CLOCKWISE:
		cursor_texture = plooy_right
	elif direction == player_direction.COUNTERCLOCKWISE:
		cursor_texture = plooy_left
	# else: use default
	if cursor_texture and cursor_texture is Texture2D:
		var img = cursor_texture.get_image()
		if img:
			if img.get_format() != Image.FORMAT_RGBA8:
				img.convert(Image.FORMAT_RGBA8)
			var scale_factor = 3.5
			var new_size = img.get_size() * scale_factor
			img.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
			var big_cursor = ImageTexture.create_from_image(img)
			Input.set_custom_mouse_cursor(big_cursor)

func remove_custom_cursor():
	Input.set_custom_mouse_cursor(null)
	custom_cursor_enabled = false

func enable_custom_cursor():
	custom_cursor_enabled = true
	set_custom_cursor()

func update_cursor_by_mouse_motion(event: InputEventMouseMotion):
	if event.relative.x < 0:
		set_custom_cursor(player_direction.COUNTERCLOCKWISE)
	elif event.relative.x > 0:
		set_custom_cursor(player_direction.CLOCKWISE)
	else:
		set_custom_cursor()

func play_sfx(sfx: Object, direction: Directions):
	if direction == player_direction.CLOCKWISE:
		sfx.pitch_scale += 0.03
		sfx.play()
	else:
		sfx.pitch_scale -= 0.03
		sfx.play()

func restart_level_sfx_vfx(sfxs: Array):
	# PERFORM SOME CUTSCENES AFTER RESTARTING
	# SFX
	for sfx in sfxs:
		sfx.play()

func change_level(scene_path: String, levels_frame):
	# Remove current level
	for child in levels_frame.get_children():
		child.queue_free()

	# Load and add new level
	var new_level = load(scene_path).instantiate()
	levels_frame.add_child(new_level)

func restart_level(levels_frame):
	# Remove and Re-open current level
	var current_level = levels_frame.get_child(0)

	if current_level:
		var level_scene = load(current_level.scene_file_path) 
		current_level.queue_free()
		var new_level = level_scene.instantiate()
		levels_frame.add_child(new_level)

extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions

const transition_time: float = 0.5
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false
var custom_cursor = preload("res://Assets/Loopling.png")

func _ready():
	set_custom_cursor()

func set_custom_cursor():
	if custom_cursor and custom_cursor is Texture2D:
		var img = custom_cursor.get_image()
		if img:
			var scale_factor = 2.5
			var new_size = img.get_size() * scale_factor
			img.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
			var big_cursor = ImageTexture.create_from_image(img)
			Input.set_custom_mouse_cursor(big_cursor)

func remove_custom_cursor():
	Input.set_custom_mouse_cursor(null)

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

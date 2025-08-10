extends Control

var new_cursor = preload("res://Assets/Loopling.png")


func set_custom_cursor():
	print("new_cursor loaded:", new_cursor)
	if new_cursor and new_cursor is Texture2D:
		# Try setting the cursor directly first
		Input.set_custom_mouse_cursor(new_cursor)
		print("Set cursor directly.")
		# Now try resizing
		var img = new_cursor.get_image()
		if img:
			var scale_factor = 2.5
			var new_size = img.get_size() * scale_factor
			img.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
			var big_cursor = ImageTexture.create_from_image(img)
			Input.set_custom_mouse_cursor(big_cursor)
			print("Set resized cursor.")
		else:
			print("Failed to get image from texture.")
	else:
		print("Cursor image not found or not a Texture2D")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_custom_cursor()


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

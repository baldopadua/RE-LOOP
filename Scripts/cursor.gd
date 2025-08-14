extends Sprite2D

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
var target_tilt: float = 0.0
var tilt_amount: float = 0.15  # About 8-9 degrees tilt
var tilt_speed: float = 12.0  # How fast it tilts
var return_speed: float = 6.0 # How fast it returns to center

func _ready():
	z_index = 1000  # Ensure it renders above everything
	centered = true

func _process(delta):
	# Follow mouse precisely
	position = get_global_mouse_position()
	
	# Smooth tilt animation
	rotation = lerp_angle(rotation, target_tilt, tilt_speed * delta)
	
	# Return to neutral position
	target_tilt = lerp(target_tilt, 0.0, return_speed * delta)

func update_cursor_direction(direction):
	match direction:
		Directions.CLOCKWISE:
			target_tilt = tilt_amount  # Tilt right
		Directions.COUNTERCLOCKWISE:
			target_tilt = -tilt_amount  # Tilt left

func _input(event):
	if event is InputEventMouseMotion:
		if event.relative.x > 1:  # Moving right
			update_cursor_direction(Directions.CLOCKWISE)
		elif event.relative.x < -1:  # Moving left
			update_cursor_direction(Directions.COUNTERCLOCKWISE)

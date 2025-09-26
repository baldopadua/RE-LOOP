extends Node2D

@onready var long_hand_rotation = $long_hand_rotation
var current_player: CharacterBody2D = null
var base_clock_position: int = 12 # Default base position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_player_reference(player: CharacterBody2D):
	current_player = player

func _on_player_moved():
	if current_player and long_hand_rotation:
		update_hand_rotation()

func get_rotation_for_clock(clock: int) -> float:
	match clock:
		12:
			return 0.0 # 12 o'clock, 0 degrees
		1:
			return deg_to_rad(30) # 1 o'clock, 30 degrees
		2:
			return deg_to_rad(60) # 2 o'clock, 60 degrees
		3:
			return deg_to_rad(90) # 3 o'clock, 90 degrees
		4:
			return deg_to_rad(120) # 4 o'clock, 120 degrees
		5:
			return deg_to_rad(150) # 5 o'clock, 150 degrees
		6:
			return deg_to_rad(180) # 6 o'clock, 180 degrees
		7:
			return deg_to_rad(210) # 7 o'clock, 210 degrees
		8:
			return deg_to_rad(240) # 8 o'clock, 240 degrees
		9:
			return deg_to_rad(270) # 9 o'clock, 270 degrees
		10:
			return deg_to_rad(300) # 10 o'clock, 300 degrees
		11:
			return deg_to_rad(330) # 11 o'clock, 330 degrees
		_:
			return 0.0

func set_hand_to_clock_position(clock_position: int):
	base_clock_position = clock_position
	var target_rotation = get_rotation_for_clock(clock_position)
	
	var tween = create_tween()
	tween.tween_property(long_hand_rotation, "rotation", target_rotation, 0.3)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

func update_hand_rotation():
	if not current_player:
		return
	
	# Get player's current rotation in degrees
	var player_rotation_deg = rad_to_deg(current_player.rotation)
	
	# Normalize the rotation to 0-360 range
	while player_rotation_deg < 0:
		player_rotation_deg += 360
	while player_rotation_deg >= 360:
		player_rotation_deg -= 360
	
	# Get base rotation for the current level
	var base_rotation = get_rotation_for_clock(base_clock_position)
	
	# Add player rotation to the base rotation
	var hand_rotation = base_rotation + deg_to_rad(player_rotation_deg)
	
	# Apply rotation to the long_hand_rotation camera
	var tween = create_tween()
	tween.tween_property(long_hand_rotation, "rotation", hand_rotation, 0.2)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

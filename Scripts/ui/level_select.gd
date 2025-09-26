extends Node2D

@onready var long_hand_rotation = $long_hand_rotation
var current_player: CharacterBody2D = null
var base_clock_position: int = 12 # Default base position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initially hide the level_select cutscene
	visible = false

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
	
	# Set hand directly to position without animation for level transitions
	long_hand_rotation.rotation = target_rotation

func update_hand_rotation():
	if not current_player:
		return
	
	# Get player's current rotation in radians
	var player_rotation = current_player.rotation
	
	# Get base rotation for the current level
	var base_rotation = get_rotation_for_clock(base_clock_position)
	
	# Calculate target hand rotation (same direction as player)
	var target_hand_rotation = base_rotation + player_rotation
	
	# Get current hand rotation
	var current_hand_rotation = long_hand_rotation.rotation
	
	# Calculate the shortest path to target rotation
	var rotation_diff = target_hand_rotation - current_hand_rotation
	
	# Normalize to shortest path (-PI to PI)
	while rotation_diff > PI:
		rotation_diff -= 2 * PI
	while rotation_diff < -PI:
		rotation_diff += 2 * PI
	
	# Apply the shortest rotation path
	var final_rotation = current_hand_rotation + rotation_diff
	
	# Apply rotation smoothly without doing full spins
	var tween = create_tween()
	tween.tween_property(long_hand_rotation, "rotation", final_rotation, 0.15)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

func show_level_complete_cutscene(_next_level_number: int):
	# MAKE CUTSCENE VISIBLE
	visible = true
	
	# HIDE ALL GAMEPLAY ELEMENTS DURING CUTSCENE
	hide_gameplay_elements()

func hide_cutscene():
	visible = false
	
	# Restore gameplay elements when cutscene is hidden
	show_gameplay_elements()

func hide_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE
	var level_scene = get_parent().get_parent().get_parent()
	if level_scene:
		# HIDE ALL LEVEL CHILDREN EXCEPT ESSENTIAL ONES
		for child in level_scene.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = false

func show_gameplay_elements():
	# NAVIGATE TO THE ACTUAL LEVEL SCENE
	var level_scene = get_parent().get_parent().get_parent()
	if level_scene:
		# RESTORE VISIBILITY OF ALL LEVEL CHILDREN
		for child in level_scene.get_children():
			if child.name not in ["SoundManager", "CanvasLayer", "Camera2D"]:
				if child.has_method("set_visible") or "visible" in child:
					child.visible = true

func get_clock_position_for_level(level_number: int) -> int:
	match level_number:
		1:
			return 12 # 12 o'clock for level 1
		2:
			return 3 # 3 o'clock for level 2
		3:
			return 6 # 6 o'clock for level 3
		4:
			return 9 # 9 o'clock for level 4
		_:
			return 12 # 12 o'clock for other levels

func animate_hand_to_next_level(next_clock_position: int) -> Tween:
	var current_rotation = long_hand_rotation.rotation
	var target_rotation = get_rotation_for_clock(next_clock_position)
	
	# Calculate the shortest rotation path
	var rotation_diff = target_rotation - current_rotation
	
	# Normalize to shortest path (-PI to PI)
	while rotation_diff > PI:
		rotation_diff -= 2 * PI
	while rotation_diff < -PI:
		rotation_diff += 2 * PI
	
	# Apply the shortest rotation path
	var final_rotation = current_rotation + rotation_diff
	
	# CREATE SMOOTH CUTSCENE ANIMATION - SHORTEST PATH ONLY
	var tween = create_tween()
	tween.tween_property(long_hand_rotation, "rotation", final_rotation, 2.0)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# UPDATE BASE POSITION AND KEEP HAND AT TARGET AFTER ANIMATION
	base_clock_position = next_clock_position
	
	# When animation finishes, set exact target rotation to prevent drift
	tween.finished.connect(func(): 
		long_hand_rotation.rotation = get_rotation_for_clock(next_clock_position)
	)
	
	return tween




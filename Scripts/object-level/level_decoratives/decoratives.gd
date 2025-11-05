extends object_class 

@onready var animated_sprite: AnimatedSprite2D = null
var total_frames: int = 16  # Total animation frames (0-15)
var previous_moves: int = 0

# TIME PERIOD FRAME RANGES
# PAST: FRAMES 0-3 (MOVES -INF TO -1)
# PRESENT: FRAMES 4-7 (MOVES 0-2)
# FUTURE: FRAMES 8-11 (MOVES 3-5)
# CLIMAX: FRAMES 12-15 (MOVES 6-11)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			animated_sprite = child
			break
	
	if animated_sprite:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
			animated_sprite.play("default")
			animated_sprite.pause()
			animated_sprite.frame = 4  

func _process(_delta: float) -> void:
	if GlobalVariables.player_moves != previous_moves:
		_update_frame()
		previous_moves = GlobalVariables.player_moves

func _update_frame() -> void:
	if not animated_sprite:
		return
	
	var player_moves = GlobalVariables.player_moves
	var frame_index: int
	
	# Determine which time period and frame based on moves
	if player_moves < 0:
		var past_progress = clamp(abs(player_moves) - 1, 0, 3) 
		frame_index = 3 - past_progress 
		
	elif player_moves <= 2:
		frame_index = 4 + player_moves
		
	elif player_moves <= 5:
		frame_index = 8 + (player_moves - 3)
		
	else:
		var climax_progress = min(player_moves - 6, 3)
		frame_index = 12 + climax_progress
	
	if not animated_sprite.is_playing():
		animated_sprite.play("default")
	
	animated_sprite.frame = frame_index
	animated_sprite.pause()
	
	animated_sprite.queue_redraw()
	
	# Debug print to verify
	var time_period = ""
	if frame_index <= 3:
		time_period = "PAST"
	elif frame_index <= 7:
		time_period = "PRESENT"
	elif frame_index <= 11:
		time_period = "FUTURE"
	else:
		time_period = "CLIMAX"
	
	print("Decorative %s: %s - frame %d (player moves: %d)" % [object_name, time_period, frame_index, player_moves])

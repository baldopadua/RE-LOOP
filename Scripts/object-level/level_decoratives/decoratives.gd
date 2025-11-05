extends object_class 

@onready var animated_sprite: AnimatedSprite2D = null
var total_frames: int = 16  
var previous_moves: int = 0

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
	if GlobalVariables.is_looping and GlobalVariables.player_moves != previous_moves:
		_update_frame()
		previous_moves = GlobalVariables.player_moves

func _update_frame() -> void:
	if not animated_sprite:
		return
	
	var player_moves = GlobalVariables.player_moves
	var frame_index: int
	
	if player_moves < 0:
		# PAST - going backward in time
		var abs_moves = abs(player_moves)
		if abs_moves == 1:
			frame_index = 3
		elif abs_moves == 2:
			frame_index = 2
		elif abs_moves == 3:
			frame_index = 1
		else:
			frame_index = 0  # -4 AND BEYOND
		
	elif player_moves <= 2:
		# PRESENT (moves 0-2): frames 4, 5, 6
		frame_index = 4 + player_moves
		
	elif player_moves <= 5:
		# FUTURE (moves 3-5): frames 7, 8, 9
		frame_index = 4 + player_moves
		
	elif player_moves <= 7:
		# CLIMAX TRANSITION (moves 6-7): frames 10, 11
		frame_index = 4 + player_moves
		
	elif player_moves == 8:
		# STAY AT FRAME 11 (gap before climax)
		frame_index = 11
		
	else:
		# CLIMAX (moves 9-11): frames 12, 13, 14
		frame_index = 3 + player_moves
	
	if not animated_sprite.is_playing():
		animated_sprite.play("default")
	
	animated_sprite.frame = frame_index
	animated_sprite.pause()
	
	animated_sprite.queue_redraw()


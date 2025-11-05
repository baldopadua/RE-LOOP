extends Node2D

@onready var map_sprite: AnimatedSprite2D = $world_environment/map
@onready var loop_break: Node2D = $loop_break
@onready var level_1_break: AnimatedSprite2D = $loop_break/level_1_break
@onready var level_2_break: AnimatedSprite2D = $loop_break/level_2_break
@onready var level_4_break: AnimatedSprite2D = $loop_break/level_4_break
@onready var level_5_break: AnimatedSprite2D = $loop_break/level_5_break
@onready var sound_manager: Node = $SoundManager
@onready var decoratives: Node2D = $decoratives

# MAP CLOCK AREA TO FRAME INDEX (OLD SYSTEM - KEEPING FOR REFERENCE)
var clock_area_to_frame := {
	12: 0, # frame 0
	3: 1,  # frame 1
	6: 2,  # frame 2
	9: 3   # frame 3
}

var previous_player_moves: int = 0
var reset_timer: Timer = null

func _ready() -> void:
	# CREATE TIMER FOR RESET TRANSITION FIRST
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.wait_time = 0.5
	reset_timer.timeout.connect(_on_reset_timer_timeout)
	add_child(reset_timer)
	
	# SET INITIAL MAP FRAME AFTER TIMER IS CREATED
	update_map_frame()

func _process(_delta: float) -> void:
	# UPDATE MAP FRAME WHEN PLAYER MOVES AND LOOPING IS ACTIVE
	if GlobalVariables.is_looping and GlobalVariables.player_moves != previous_player_moves:
		update_map_frame()
		previous_player_moves = GlobalVariables.player_moves

func update_map_frame() -> void:
	var player_moves = GlobalVariables.player_moves
	var map_frame: int
	var map_modulate := Color(1, 1, 1, 1) 
	
	if player_moves == 12:
		# SHOW FRAME 3 FOR 0.5 SECONDS BEFORE RESET (from future/climax)
		map_sprite.frame = 3
		map_sprite.modulate = Color(1, 1, 1, 1)  
		map_sprite.pause()
		print("MAP FRAME UPDATE - player_moves: %d, map_frame: 3 (waiting for reset from future)" % player_moves)
		if reset_timer and not reset_timer.is_stopped():
			reset_timer.stop()
		if reset_timer:
			reset_timer.start()
		return
	elif player_moves == -12:
		# SHOW FRAME 0 WITH VIOLET FOR 0.5 SECONDS BEFORE RESET (from past)
		map_sprite.frame = 0
		map_sprite.modulate = Color(1.0, 0.75, 1.0, 1)  # Deep violet (same as -9+)
		map_sprite.pause()
		print("MAP FRAME UPDATE - player_moves: %d, map_frame: 0 violet (waiting for reset from past)" % player_moves)
		if reset_timer and not reset_timer.is_stopped():
			reset_timer.stop()
		if reset_timer:
			reset_timer.start()
		return
	
	# NORMAL FRAME UPDATES
	if player_moves == 0:
		# STOP ANY PENDING RESET TIMER
		if reset_timer and not reset_timer.is_stopped():
			reset_timer.stop()
		map_frame = 0
	elif player_moves < 0:
		# GOING BACKWARDS IN TIME - all use frame 0 with violet tint
		map_frame = 0
		var abs_moves = abs(player_moves)
		
		if abs_moves <= 2:
			# -1 to -2: frame 0, normal color
			map_modulate = Color(1.0, 1.0, 1.0, 1)
		elif abs_moves <= 5:
			# -3 to -5: frame 0 with subtle violet
			var violet_progress = (abs_moves - 2) / 3.0
			var red = 1.0
			var green = 1.0 - (violet_progress * 0.10)
			var blue = 1.0
			map_modulate = Color(red, green, blue, 1)
		else:
			# -6+: frame 0 with more violet (deeper past)
			var violet_progress = min((abs_moves - 5) / 4.0, 1.0)
			var red = 1.0
			var green = 0.9 - (violet_progress * 0.15)
			var blue = 1.0
			map_modulate = Color(red, green, blue, 1)
	elif player_moves <= 2:
		map_frame = 0
	elif player_moves <= 5:
		map_frame = 1
	elif player_moves <= 8:
		map_frame = 2
	else:
		# MOVES 9-11 SHOW FRAME 3 (CLIMAX)
		map_frame = 3
	
	map_sprite.frame = map_frame
	map_sprite.modulate = map_modulate
	map_sprite.pause()
	
	print("MAP FRAME UPDATE - player_moves: %d, map_frame: %d, modulate: (%.2f, %.2f, %.2f)" % [player_moves, map_frame, map_modulate.r, map_modulate.g, map_modulate.b])

func _on_reset_timer_timeout() -> void:
	map_sprite.frame = 0
	map_sprite.modulate = Color(1, 1, 1, 1) 
	map_sprite.pause()
	print("MAP RESET - frame now 0 after timer")

func show_map_for_clock_area(_clock_area: int) -> void:
	# DISABLED - now using player_moves based system
	# Keep this for backward compatibility if needed but don't actually update
	pass
	#if clock_area in clock_area_to_frame:
		#map_sprite.frame = clock_area_to_frame[clock_area]
		#map_sprite.pause()

# MIDDLE BREAK LOOP LOGIC
func show_loop_break(level: int) -> void:
	loop_break.visible = true
	level_1_break.visible = false
	level_2_break.visible = false 
	level_4_break.visible = false 
	if level == 1:
		level_1_break.visible = true
		level_1_break.play()
	elif level == 2:
		level_2_break.visible = true
		level_2_break.play()
	elif level == 4:
		level_4_break.visible = true
		level_4_break.play()
	elif level == 5:
		level_5_break.visible = true
		level_5_break.play()

# SHOW DECORATIVES FOR SPECIFIC LEVEL
func show_decoratives(level: int) -> void:
	for child in decoratives.get_children():
		child.visible = false
	var level_node = decoratives.get_node_or_null("level_%d" % level)
	if level_node:
		level_node.visible = true
		_update_decorative_frames(level_node)
	else:
		push_warning("Level %d decoratives not found" % level)

# UPDATE FRAMES FOR ALL DECORATIVES IN A LEVEL
func _update_decorative_frames(level_node: Node2D) -> void:
	for child in level_node.get_children():
		if child.has_method("_update_frame"):
			child._update_frame()

func hide_all_decoratives() -> void:
	decoratives.visible = false

func show_all_decoratives() -> void:
	decoratives.visible = true

extends Node2D

@onready var map_sprite: AnimatedSprite2D = $world_environment/map
@onready var loop_break: Node2D = $loop_break
@onready var level_1_break: AnimatedSprite2D = $loop_break/level_1_break
@onready var level_2_break: AnimatedSprite2D = $loop_break/level_2_break
@onready var level_4_break: AnimatedSprite2D = $loop_break/level_4_break
@onready var level_5_break: AnimatedSprite2D = $loop_break/level_5_break
@onready var sound_manager: Node = $SoundManager
@onready var decoratives: Node2D = $decoratives

# Map clock area to frame index
var clock_area_to_frame := {
	12: 0, # frame 0
	3: 1,  # frame 1
	6: 2,  # frame 2
	9: 3   # frame 3
}

func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	pass

func show_map_for_clock_area(clock_area: int) -> void:
	if clock_area in clock_area_to_frame:
		map_sprite.frame = clock_area_to_frame[clock_area]
		map_sprite.pause()

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

# Show decoratives for specific level
func show_decoratives(level: int) -> void:
	# Hide all level decoratives first
	for child in decoratives.get_children():
		child.visible = false
	
	# Show the requested level
	var level_node = decoratives.get_node_or_null("level_%d" % level)
	if level_node:
		level_node.visible = true
	else:
		push_warning("Level %d decoratives not found" % level)

# Hide all decoratives
func hide_all_decoratives() -> void:
	decoratives.visible = false

# Show decoratives node
func show_all_decoratives() -> void:
	decoratives.visible = true

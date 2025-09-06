extends Node2D

@onready var map_sprite: AnimatedSprite2D = $world_environment/map
@onready var loop_break: Node2D = $loop_break
@onready var level_1_break: AnimatedSprite2D = $loop_break/level_1_break
@onready var level_2_break: AnimatedSprite2D = $loop_break/level_2_break
@onready var sound_manager: Node = $SoundManager

# Map clock area to frame index
var clock_area_to_frame := {
	12: 0, # frame 0
	3: 1,  # frame 1
	6: 2,  # frame 2
	9: 3   # frame 3
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_map_for_clock_area(clock_area: int) -> void:
	if clock_area in clock_area_to_frame:
		map_sprite.frame = clock_area_to_frame[clock_area]
		map_sprite.pause()

func show_loop_break(level: int) -> void:
	loop_break.visible = true
	level_1_break.visible = false
	level_2_break.visible = false 
	if level == 1:
		level_1_break.visible = true
		level_1_break.play()
	elif level == 2:
		level_2_break.visible = true
		level_2_break.play()

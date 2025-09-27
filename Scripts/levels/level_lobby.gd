extends Node2D

@export var source_tilemap: TileMapLayer

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager


var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0, 0)

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

@onready var enter_1: object_class = $enter_1
@onready var enter_2: object_class = $enter_2
@onready var enter_3: object_class = $enter_3
@onready var enter_4: object_class = $enter_4

func _ready():
	level_handler.set_current_lobby()
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# Make clock visible in lobby for level selection but hide the clock texture
	level_handler.level_select_node.visible = true
	level_handler.level_select_node.get_node("level_clock").visible = false
	
	level_handler.visible = false

	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
func objects_initialize():
	objects.append(enter_1)
	objects.append(enter_2)
	objects.append(enter_3)
	objects.append(enter_4)

func _process(_delta: float) -> void:
	level_handler.visible = true

# Add this method to handle level transitions from lobby
func enter_level(level_number: int):
	print("Entering level ", level_number)
	
	# Get the levels_frame from the game scene structure
	var levels_frame = get_parent()  # This should be the levels_frame
	
	# Kill the current lobby map with animation
	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# Use level_handler's load_next_level method
	level_handler.load_next_level(level_number, levels_frame)



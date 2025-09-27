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

func _process(_delta: float) -> void:
	level_handler.visible = true

# Add this method to handle level transitions from lobby
func enter_level(level_number: int):
	print("Entering level ", level_number)
	
	# Kill the current lobby map with animation
	level_handler.kill_current_level(self)
	await get_tree().create_timer(1.0).timeout
	
	# Load the selected level
	var level_path = "res://Scenes/levels/level_" + str(level_number) + "_scene.tscn"
	get_tree().change_scene_to_file(level_path)



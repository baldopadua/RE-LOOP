extends Node2D

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []
@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager

# LEVEL 5 OBJECTS
@onready var science_project = $science_project
@onready var vending = $vending
@onready var rocket = $rocket
@onready var dreamer = $dreamer

# PLAYER STATE AND LABEL
var player_has_entered: bool = false

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

func _ready():
	# SET LEVEL
	level_handler.set_current_level(5)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()

func objects_initialize():
	
	objects.append(science_project)
	objects.append(vending)
	objects.append(rocket)
	objects.append(dreamer)


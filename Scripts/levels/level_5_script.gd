extends Node2D

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []
@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
#@onready var anim_handler = $AnimationHandler

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
	pass

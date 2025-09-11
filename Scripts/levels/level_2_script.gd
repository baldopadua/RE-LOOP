extends Node2D

# TILEMAP AND PLAYER
@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

# OBJECTS
@onready var old_man: object_class = $old_man
@onready var sword: object_class = $Sword
var objects: Array = []

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $LevelHandler

# TWEENS
var tween_rotate: Tween
var tween_scale: Tween

func _ready():
	
	# INTRO OF MAP ROTATE AND SCALE PLUS TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	
	# INITIALIE OBJECTS
	objects_initialize()
	
func objects_initialize():
	objects.append(old_man)
	objects.append(sword)
	
func _process(_delta: float) -> void:
	pass

# Example function to play a sound effect using the centralized sound manager
func play_level2_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

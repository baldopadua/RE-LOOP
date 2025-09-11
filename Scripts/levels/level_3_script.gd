extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene
@onready var geyser = $geyser
var objects: Array = []

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $LevelHandler

# TWEENS
var tween_rotate: Tween
var tween_scale: Tween

func _ready():
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	objects_initialize()

func objects_initialize():
	# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(geyser)
	objects.append(sound_manager) # Add SoundManager to objects array

func play_level3_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene
@onready var geyser = $geyser
var objects: Array = []

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $CanvasLayer/LevelHandler

# TWEENS
var tween_rotate: Tween
var tween_scale: Tween

func _ready():
	# SET LEVEL
	level_handler.set_current_level(3)
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	objects_initialize()
	
	player.rotation = deg_to_rad(90.0)

func objects_initialize():
	# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(geyser)
	objects.append(sound_manager) # Add SoundManager to objects array

func play_level3_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 

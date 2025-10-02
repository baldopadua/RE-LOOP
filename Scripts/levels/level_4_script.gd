extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler

@onready var bone = $bone
@onready var chicken = $chicken
@onready var lizard = $lizard
@onready var dog = $dog
@onready var incubator = $incubator
@onready var trex = $trex
@onready var stick = $stick

func _ready():
	# SET LEVEL
	level_handler.set_current_level(4)
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	
	objects_initialize()

func objects_initialize():
		# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(bone)
	objects.append(chicken)
	objects.append(lizard)
	objects.append(dog)
	objects.append(incubator)
	objects.append(trex)
	objects.append(stick)

# If the Plooy being tail whipped animation is finished go to level 5
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tail_whipped":
		level_handler.complete_current_level(get_parent())

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 

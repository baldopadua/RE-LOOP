extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler

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

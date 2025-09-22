extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $LevelHandler

@onready var soil = $soil
@onready var stick = $soil/stick
@onready var bone = $bone
@onready var statues = $statues1
@onready var statues2 = $statues2
@onready var statues3 = $statues3
@onready var chicken = $chicken
@onready var lizard = $lizard
@onready var dog = $dog
@onready var incubator = $incubator
@onready var seed = $seed

func _ready():
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	
	objects_initialize()

func objects_initialize():
		# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(soil)
	objects.append(stick)
	objects.append(bone)
	objects.append(statues)
	objects.append(statues2)
	objects.append(statues3)
	objects.append(chicken)
	objects.append(lizard)
	objects.append(dog)
	objects.append(incubator)
	objects.append(seed)

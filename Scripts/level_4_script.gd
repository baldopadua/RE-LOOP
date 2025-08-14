extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

# SFX
@onready var cinematic_impact: Object = $cinematic_impact
@onready var glass_break: Object = $glass_break
@onready var ice_break: Object = $ice_break
@onready var time_freeze: Object = $time_freeze
@onready var underwater_explosion: Object = $underwater_explosion
@onready var bell: Object = $bell

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []
@onready var soil = $soil
@onready var stick = $stick
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
	GlobalVariables.is_looping = true
	GlobalVariables.player_stopped = false
	
	# INITIALLY ROTATE TO 360 DEGREES
	rotation = deg_to_rad(360.0)
	# INITIALLY SET THE SCALE TO 0
	scale = Vector2(0.0,0.0)
	
	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	# Connect tween_finished if not yet connected
	if not tween_rotate.is_connected("finished", _tween_rotation_finished):
		tween_rotate.connect("finished", _tween_rotation_finished)
	var rotation_tween = rotation - deg_to_rad(360.0)
	tween_rotate.tween_property(self, "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	if not tween_scale.is_connected("finished", _tween_scale_finished):
		tween_scale.connect("finished", _tween_scale_finished)
	tween_scale.tween_property(self, "scale", Vector2(1.0,1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
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

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()

func _process(_delta: float) -> void:
	pass

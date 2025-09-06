extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene
@onready var geyser = $geyser
@onready var sound_manager = $SoundManager

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

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
	objects.append(geyser)
	objects.append(sound_manager) # Add SoundManager to objects array

func play_level3_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()

func _process(_delta: float) -> void:
	pass

extends Node2D

@export var source_tilemap: TileMapLayer
@onready var seed_obj = $Seed
@onready var soil = $Soil
@onready var tree = $tree
@onready var objects: Array = []
@onready var player = $PlayerScene
@onready var area_handler = $AreaHandler
var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0,0)

# SFX
@onready var sound_manager = $SoundManager

var tween_rotate: Tween
var tween_scale: Tween

func _ready():
	GlobalVariables.is_looping = true
	
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
	# Connect tween_finished if not yet connected
	if not tween_scale.is_connected("finished", _tween_scale_finished):
		tween_scale.connect("finished", _tween_scale_finished)
	tween_scale.tween_property(self, "scale", Vector2(1.0,1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	objects.append(soil)
	objects.append(tree)
	objects.append(seed_obj)

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()

# If seed is planted in soil
# Tree can now cycle

func _process(_delta: float) -> void:
	if soil.has_node("Seed") and GlobalVariables.is_looping:
		seed_obj.visible = false
		tree.visible = true
		# SET THE TREE MAX AND MIN STATE TO START INCREMENTING
		if tree.max_state_threshold == 0 and tree.min_state_threshold == 0 and tree.current_state == 0:
			tree.max_state_threshold = 4
			tree.min_state_threshold = 1
			tree.current_state = 1
		update_tree_visibility(tree.current_state)

func update_tree_visibility(stage: int) -> void:
	# stage is 1-based, so we subtract 1 for array index
	var index = clamp(stage - 1, 0, states.size() - 1)
	for i in range(states.size()):
		tree.get_node(states[i]).visible = (i == index)
	if stage == 4:
		# Stop
		area_handler.show_loop_break(1)
		GlobalVariables.is_looping = false
		GlobalVariables.player_stopped = true
		# Play SFX using SoundManager for finish_level_sfx nodes
		if sound_manager and sound_manager.has_method("play_finish_level_sfx"):
			sound_manager.play_finish_level_sfx()
		await get_tree().create_timer(1.0).timeout
		GlobalVariables.player_stopped = false
		return



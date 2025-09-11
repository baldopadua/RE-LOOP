extends Node2D

@export var source_tilemap: TileMapLayer

# OBJECTS
@onready var seed_obj = $Seed
@onready var soil = $Soil
@onready var tree = $tree

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $LevelHandler
@onready var sound_manager = $SoundManager

var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0, 0)

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

func _ready():
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()

func objects_initialize():
	objects.append(soil)
	objects.append(tree)
	objects.append(seed_obj)
 
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

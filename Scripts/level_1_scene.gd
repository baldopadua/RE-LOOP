extends Node2D

@export var source_tilemap: TileMapLayer
@onready var seed_obj = $Seed
@onready var soil = $Soil
@onready var tree = $tree
@onready var player = $PlayerScene
var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0,0)

# SFX
@onready var cinematic_impact: Object = $cinematic_impact
@onready var glass_break: Object = $glass_break
@onready var ice_break: Object = $ice_break
@onready var time_freeze: Object = $time_freeze
@onready var underwater_explosion: Object = $underwater_explosion
@onready var bell: Object = $bell

func _ready():
	GlobalVariables.is_looping = true

# If seed is planted in soil
# Tree can now cycle

func _process(_delta: float) -> void:
	if soil.has_node("Seed") and GlobalVariables.is_looping:
		soil.visible = false
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
		GlobalVariables.is_looping = false
		GlobalVariables.player_stopped = true
		cinematic_impact.play()
		glass_break.play()
		ice_break.play()
		bell.play()
		await get_tree().create_timer(3.0).timeout
		bell.play()
		underwater_explosion.play()
		await get_tree().create_timer(3.0).timeout
		bell.play()
		GlobalVariables.player_stopped = false
		return

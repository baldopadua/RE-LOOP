extends Node2D

@export var source_tilemap: TileMapLayer
@onready var seed = $Seed
@onready var soil = $Soil
@onready var tree = $tree
@onready var player = $PlayerScene
var states := ["State1", "State2", "State3", "State4", "State5"]
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

func _process(delta: float) -> void:
	if soil.has_node("Seed") and GlobalVariables.is_looping:
		soil.visible = false
		tree.visible = true
		update_tree_visibility(player.player_clock_position)

func update_tree_visibility(stage: int) -> void:
	# stage is 1-based, so we subtract 1 for array index
	var index = clamp(stage - 1, 0, states.size() - 1)
	for i in range(states.size()):
		tree.get_node(states[i]).visible = (i == index)
	if stage == 5:
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

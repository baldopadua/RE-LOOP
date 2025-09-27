extends Node2D

@export var source_tilemap: TileMapLayer

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []

@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager


var states := ["State1", "State2", "State3", "State4"]
var center_circle: Vector2i = Vector2i(0, 0)

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

func _ready():
	level_handler.set_current_lobby()
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)

	# Make clock visible in lobby for level selection
	level_handler.level_select_node.visible = true
	
	level_handler.visible = false


func _process(_delta: float) -> void:
	level_handler.visible = true
	
		

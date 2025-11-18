extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

# HANDLERS
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# LEVEL 10 OBJECTS
@onready var laser = $Laser
@onready var nicola_tesla = $NicolaTesla
@onready var thomas_edison = $ThomasEdison
@onready var benjamin_franklin = $BenjaminFranklin
@onready var tesla_coil = $TeslaCoil
@onready var lightning_cloud = $LightningCloud
@onready var light_bulb = $LightBulb

func _ready():
	# SET LEVEL
	level_handler.set_current_level(10)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
	player.rotation = deg_to_rad(300.0)
	
	initial_cinematic()

func objects_initialize():
	objects.append(laser)
	objects.append(nicola_tesla)
	objects.append(thomas_edison)
	objects.append(benjamin_franklin)
	objects.append(tesla_coil)
	objects.append(lightning_cloud)
	objects.append(light_bulb)

func initial_cinematic():
	player.set_process_input(false)
	await get_tree().create_timer(1.0).timeout
	var p = player.get_node("Camera2D")
	
	p.emit_signal("cam_zoom", 1.5)
	p.emit_signal("reveal_bars")
	p.emit_signal("pan_to_pos", light_bulb.global_position)
	
	await get_tree().create_timer(1.5).timeout
	
	p.emit_signal("pan_to_pos", tesla_coil.global_position)
	
	await get_tree().create_timer(1.5).timeout
	
	p.emit_signal("pan_to_pos", lightning_cloud.global_position)
	
	await get_tree().create_timer(1.5).timeout
	
	p.emit_signal("pan_to_pos", laser.get_node("AnimatedSprite2D").global_position)
	
	await get_tree().create_timer(2.0).timeout
	
	p.emit_signal("cam_orig_zoom")
	p.emit_signal("hide_bars")
	p.emit_signal("pan_to_orig_pos")
	
	player.set_process_input(true)

func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 10:
		level_handler.complete_current_level(get_parent())

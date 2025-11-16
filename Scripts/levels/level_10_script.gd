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

func objects_initialize():
	objects.append(laser)
	objects.append(nicola_tesla)
	objects.append(thomas_edison)
	objects.append(benjamin_franklin)
	objects.append(tesla_coil)
	objects.append(lightning_cloud)
	objects.append(light_bulb)

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	

extends Node2D

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []
@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# LEVEL 5 OBJECTS
@onready var science_project = $science_project
@onready var vending = $vending
@onready var rocket = $rocket
@onready var dreamer = $dreamer

# PLAYER STATE AND LABEL
var player_has_entered: bool = false
@onready var player_label: Label = $PlayerScene/Label  # Corrected path
@onready var temp_timer: Timer = Timer.new()  # Create timer


# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

func _ready():
	# SET LEVEL
	level_handler.set_current_level(5)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# SHOW DECORATIVES
	area_handler.show_decoratives(5)
	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
	player.rotation = deg_to_rad(150.0)
	
	# Add timer to scene tree and configure
	add_child(temp_timer)
	temp_timer.one_shot = true
	if player_label:
		player_label.visible = false

func objects_initialize():
	
	objects.append(science_project)
	objects.append(vending)
	objects.append(rocket)
	objects.append(dreamer)
	objects.append(sound_manager)

func play_level5_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

func play_rocket_countdown():
	play_level5_sfx("rocket_countdown")

func play_rocket_launch_sequence():
	play_level5_sfx("rocket_ignition")
	await get_tree().create_timer(2.0).timeout  # Wait for ignition
	play_level5_sfx("rocket_launch")

func play_science_project_activate():
	play_level5_sfx("science_project_activate")

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 


# If the rocket animation is finished go to level 6
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "rocket_animation":
		if not player_has_entered:
			if player_label:
				player_label.visible = true
			temp_timer.start(3.0)
			temp_timer.timeout.connect(func():
				level_handler.restart_level(get_parent())
			)
		else:
			# Player successfully entered the rocket and animation finished
			level_handler.complete_current_level(get_parent())
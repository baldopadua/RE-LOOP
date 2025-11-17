extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# Objects
# Monk
@onready var monk = $monk
# Statues
@onready var tree_statue = $tree_statue
@onready var hero_statue = $hero_statue
@onready var geyser_statue = $geyser_statue
@onready var dinosaur_statue = $dinosaur_statue
@onready var rocket_statue = $rocket_statue
@onready var apple_statue = $apple_statue
@onready var butterfly_statue = $butterfly_statue
@onready var turtle_statue = $turtle_statue
@onready var cat_statue = $cat_statue
@onready var electric_statue = $electric_statue
@onready var plooy_statue = $plooy_statue
# Keystones
@onready var seed = $seed
@onready var skull = $skull
@onready var rock = $rock
@onready var egg = $egg
@onready var soda = $soda
@onready var apple = $apple
@onready var butterfly = $butterfly
@onready var carrot = $carrot
@onready var cat = $cat
@onready var lightbulb = $lightbulb

func _ready():
	# SET LEVEL
	level_handler.set_current_level(11)
	ui_handler.disable_game_ui_elements()
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()

	player.rotation = deg_to_rad(330.0)
	GlobalVariables.is_looping = false
	var bg = get_parent().get_parent().get_node("CanvasLayer").get_node("game_scene_bg")
	
	# disable movement
	player.set_process_input(false)
	
	# wait 1 second
	await get_tree().create_timer(1.0).timeout
	
#	hide game elements
	ui_handler.hide_game_ui_elements()
	
	# Zoom out a lil bit
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.65)
	# reveal cinematic bars
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	# Slow down time to 0.1 under 1 seconds
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", 0.1, 1.0)
	
	# while slowing down time, toggle grayscale
	toggle_grayscale(bg)
	toggle_grayscale(area_handler.map_sprite)
	# toggle grayscale for keystones
	#toggle_grayscale(seed.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(skull.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(rock.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(egg.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(soda.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(apple.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(butterfly.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(carrot.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(cat.get_node("AnimatedSprite2D2"))
	#toggle_grayscale(lightbulb.get_node("AnimatedSprite2D2"))
	
	# wait for slowing time to be finished then pause bg and set time scale back to normal
	await tween.finished
	bg.pause()
	tween_time_scale(1.0, 1.0)
	
	# Camera to Monk
	player.get_node("Camera2D").emit_signal("pan_to_pos", monk.global_position)
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	
	# Dialogue here
	DialogueManager.show_dialogue_balloon_scene("res://dialogues/made/balloon.tscn", load("res://dialogues/initial_meeting.dialogue"))
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	

func _on_dialogue_ended(_resource: DialogueResource):
	# Refocus original position
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
		
	# Enable player movement
	player.set_process_input(true)
#	Reshow ui elements
	ui_handler.show_game_ui_elements()


# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	
func toggle_grayscale(bg):
	var current = bg.material.get("shader_parameter/gray_amount")
	var target = 1.0 if current < 0.5 else 0.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(bg.material, "shader_parameter/gray_amount", target, 0.5)

func tween_time_scale(target: float, duration: float = 0.5):
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", target, duration)


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 11:
		level_handler.complete_current_level(get_parent())

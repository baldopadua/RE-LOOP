extends object_class

# TWEENS
var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween

var level_2 = preload("res://Scenes/levels/level_2_scene.tscn")
var time_indicator: AnimatedSprite2D
var is_playing: bool = false

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $"../LevelHandler"
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var anim_handler = $"../AnimationPlayer"

func _ready() -> void:
	pass
	
func _on_body_entered(body) -> void:
	handle_body_entered(body)
	
	# CLIMB THE TREE
	if not GlobalVariables.is_looping and not is_playing:
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
			
		await get_tree().create_timer(1).timeout
		
		ui_handler.set_time_indicator_fixed()
		ui_handler.set_default_time_indicator()

		
		# PLAY CLIMB ANIMATION
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		
		# 1. REMOVE TWEEN 
	
		sound_manager.play_player_sfx("Climb")
		anim_handler.play("ClimbingAnimation")
		
		# Wait for climbing animation to be finished

func _tween_climb_finished():
	tween_climb.kill()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ClimbingAnimation":
		# DECLARE LEVEL TO BE FINISHED
		var level_1 = get_parent()
		level_handler.next_level(level_1, tween_rotate, tween_scale, "res://Scenes/levels/level_2_scene.tscn")
		
		# CODE FOR PLAYING AnimatedSprite2D na nag jujump yung player sa hole.

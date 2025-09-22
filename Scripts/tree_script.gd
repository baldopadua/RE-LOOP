extends object_class

# TWEENS
var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween

var level_2 = preload("res://Scenes/levels/level_2_scene.tscn")
var time_indicator: AnimatedSprite2D
var is_playing: bool = false
var player_body: Node 

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $"../LevelHandler"
@onready var anim_handler = $"../AnimationPlayer"

func _ready() -> void:
	time_indicator = get_parent().get_parent().get_parent().get_node("CanvasLayerGameUi").get_node("game_ui_elements").get_node("ui_frame").get_node("time_indicator")

func _on_body_entered(body) -> void:
	handle_body_entered(body)
	
	# CLIMB THE TREE
	if not GlobalVariables.is_looping and not is_playing:
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		
		# STORE THE PLAYER REFERENCE
		player_body = body
			
		await get_tree().create_timer(1).timeout
		
		# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
		time_indicator.animation = "fixed"
		time_indicator.frame = 0
		time_indicator.pause()
		
		# PLAY CLIMB ANIMATION ON PLAYER SPRITE
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		sound_manager.play_player_sfx("Climb")
		anim_handler.play("ClimbingAnimation")

func _tween_climb_finished():
	tween_climb.kill()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ClimbingAnimation":
		# Play jump animation on player sprite after climbing finishes
		if player_body and player_body.has_node("AnimatedSprite2D"):
			var sprite = player_body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("jump")
		
		# Play jump animation in AnimationPlayer
		anim_handler.play("JumpAnimation")
	elif anim_name == "JumpAnimation":
		# DECLARE LEVEL TO BE FINISHED
		var level_1 = get_parent()
		level_handler.next_level(level_1, tween_rotate, tween_scale, "res://Scenes/levels/level_2_scene.tscn")

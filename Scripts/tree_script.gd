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
			
		await get_tree().create_timer(1).timeout
		
		# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
		time_indicator.animation = "fixed"
		time_indicator.frame = 0
		time_indicator.pause()
		
		# PLAY CLIMB ANIMATION
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		tween_climb = create_tween()
		
		# Connect tween_finished if not yet connected
		if not tween_climb.is_connected("finished", _tween_climb_finished):
			tween_climb.connect("finished", _tween_climb_finished)
	
		sound_manager.play_player_sfx("Climb")
		
		var screen_center = Vector2(0.0, 250.0)
		tween_climb.tween_property(body, "position", screen_center, 1.5).set_trans(Tween.TRANS_LINEAR)
		await tween_climb.finished
		
		body.visible = false

		# DECLARE LEVEL TO BE FINISHED
		var level_1 = get_parent()
		level_handler.next_level(level_1, tween_rotate, tween_scale, "res://Scenes/levels/level_2_scene.tscn")

func _tween_climb_finished():
	tween_climb.kill()

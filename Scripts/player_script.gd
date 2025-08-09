extends CharacterBody2D

var player_directions = GlobalVariables.player_direction
@export var direction: GlobalVariables.player_direction

const angle_per_move := 30 # The that will be added everytime player rotates
var is_moving: bool = false
var tween: Tween
var transition_time = GlobalVariables.transition_time

# TODO: Change this later to animated sprite
@onready var sprite = $Sprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_right") and round(rad_to_deg(rotation)) < 180.0 and not is_moving:
		direction = player_directions.RIGHT
		rotate_player()
	elif event.is_action_pressed("move_left") and round(rad_to_deg(rotation)) > -180.0 and not is_moving:
		direction = player_directions.LEFT
		rotate_player()
	# MAX TURNS REACHED
	elif (event.is_action_pressed("move_right") or event.is_action_pressed("move_left")) and (round(rad_to_deg(rotation)) == 180.0 or round(rad_to_deg(rotation)) == -180.0) and not is_moving:
		print("MAX TURNS REACHED!")
func _tween_finished():
	tween.kill()
	is_moving = false
	pass

# Movement of Player
func rotate_player():
	# Asynchrnously start the scene transition here
	# Some async func to start reversing or forwarding time
	
	# Player is moving and create a tween to smooth animation
	is_moving = true
	tween = create_tween()
	
	# Connect tween_finished if not yet connected
	if not tween.is_connected("finished", _tween_finished):
		tween.connect("finished", _tween_finished)
		
	# Rotate based on direction
	var rotation_tween: float
	if direction == player_directions.RIGHT:
		rotation_tween = rotation + deg_to_rad(angle_per_move)
		sprite.flip_h = false
	else:
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		sprite.flip_h = true
		
	# set the tween
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
func _process(delta):
	pass

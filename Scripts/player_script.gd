extends CharacterBody2D

@export var center := Vector2(0,0)  # center of the ring
@export var radius := 300.0 # distance from center
@export var speed := 2.0 # radians per second

var angle := 0.0 # current angle around circle

#func _input(event: InputEvent) -> void:
	#pass

func _process(delta):
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	angle += speed * input_dir * delta
	angle = fmod(angle, TAU)  # keep angle in [0, 2π]

	# Update position around circle
	position = center + Vector2(cos(angle), sin(angle)) * radius

	# Rotate to face direction
	rotation = angle + PI / 2

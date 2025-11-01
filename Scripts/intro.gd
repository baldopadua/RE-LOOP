extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var godot_bg = $godot_bg
@onready var godot = $godot
@onready var patir_bg = $patir_bg
@onready var patir_studio = $patir_studio

func _ready():
	# Set all as false first
	godot_bg.visible = false
	godot.visible = false
	patir_bg.visible = false
	patir_studio.visible = false
	
	# Play godot animation first
	animation_player.play("godot")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "godot":
		# After godot animation, play patir
		animation_player.play("patir")
	elif anim_name == "patir":
		# Smooth fade to black using tween
		var tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(self, "modulate", Color.BLACK, 0.5)
		tween.tween_callback(_change_to_main_scene)

func _change_to_main_scene():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")

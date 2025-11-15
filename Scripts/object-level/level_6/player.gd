extends "res://Scripts/player_script.gd"

@onready var in_1 = $"../isaac_newton_1"
@onready var in_2 = $"../isaac_newton_2"
@onready var seed1 = $"../seed"
@onready var seed2 = $"../seed2"
@onready var canvas_layer = $"../CanvasLayer"
@onready var switch_circle = $"../switch_circle"

var matched = false

func _on_player_finished_moving() -> void:
	if not matched:
		if in_1.matched and in_2.matched and seed1.matched and seed2.matched:
			if in_1.current_state == in_2.current_state and seed1.current_state == seed2.current_state:
				GlobalVariables.player_stopped = true
				set_process_input(false)
				
				await get_tree().create_timer(1.0).timeout
				
				# HIDE THE UI DURING CINEMA
				ui_handler.hide_game_ui_elements()
				get_node("Camera2D").emit_signal("reveal_bars")
				get_node("Camera2D").emit_signal("cam_zoom", 0.75)
				shake_camera(5.0, 10.0, 2.5)
				
				await get_tree().create_timer(2.5).timeout
				
				var flash = ColorRect.new()
				flash.color = Color(1, 1, 1, 1)
				flash.anchor_right = 1
				flash.anchor_bottom = 1
				canvas_layer.add_child(flash)

				# Do all things before transitionting here...
				area_handler.get_node("world_environment").get_node("map").animation = "default"
				position.x = 0.0
				in_1.is_pickupable = false
				in_2.is_pickupable = false
				seed1.is_pickupable = false
				seed2.is_pickupable = false
				in_2.visible = false
				seed2.visible = false
				switch_circle.visible = false
				in_1.position.x = 0.0
				seed1.position.x = 0.0
				in_1.animated_sprite.play("default")
				in_1.animated_sprite2.play("default")
				seed1.animated_sprite.play("tree")
				seed1.animated_sprite2.play("tree")
				in_1.current_state = 2
				seed1.current_state = 4
				matched = true
				# Reveal all the keystones here

				# Fade out animation
				flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
				
				await get_tree().create_timer(1.0).timeout
				
				get_node("Camera2D").emit_signal("cam_orig_zoom")
				area_handler.show_loop_break(6)

extends "res://Scripts/player_script.gd"

@onready var cat = $"../cat"
@onready var cat2 = $"../cat2"
@onready var s1 = $"../schrodinger"
@onready var s2 = $"../schrodinger2"
@onready var lever1 = $"../lever"
@onready var lever2 = $"../lever2"
@onready var box = $"../box"
@onready var canvas_layer = $"../CanvasLayer"
@onready var switch_circle = $"../switch_circle"
@onready var center_pos = $"../center_pos"
signal loop_break_shown # Add this signal

var matched = false


func _on_player_finished_moving() -> void:
	
	# check if both cat states are the same
	if not box.box_closed and box.cat_placed and box.cat2_placed:
		if cat.current_state == cat2.current_state:
			# play box close function
			box.close_box_function()
	
	if not matched:
		if s1.matched and s2.matched and lever2.matched and box.box_closed:
			if s1.current_state == s2.current_state:
				GlobalVariables.player_stopped = true
				set_process_input(false)
				
				await get_tree().create_timer(2.0).timeout
				
				lever1.get_node("AnimatedSprite2D").play("default")
				lever2.get_node("AnimatedSprite2D").play("default")
				lever2.get_node("AnimatedSprite2D2").play("default")
				
				# HIDE THE UI DURING CINEMA
				ui_handler.hide_game_ui_elements()
				get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
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
				s1.is_pickupable = false
				s2.is_pickupable = false
				lever2.is_pickupable = false
				s2.visible = false
				lever2.visible = false
				box.visible = true
				cat.visible = true
				switch_circle.visible = false
				s1.position.x = -101.0
				lever1.position.x = -101.0
				s1.position.y = 280.0
				lever1.position.y = 280.0
				s1.animated_sprite1.play_backwards("default")
				s1.animated_sprite2.play_backwards("default")
				s1.current_state = 1
				get_node("Camera2D").emit_signal("pan_to_orig_pos")
				matched = true
				# Reveal all the keystones here
				position.x = 0.0
				

				# Fade out animation
				flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
				
				await get_tree().create_timer(1.0).timeout
				box.open_box_function()
				get_node("Camera2D").emit_signal("cam_orig_zoom") #
				await get_tree().create_timer(4.0).timeout
				area_handler.show_loop_break(9)
				emit_signal("loop_break_shown") 

				# After the loop break, hide bars and enable player movement
				get_node("Camera2D").emit_signal("hide_bars")
				set_process_input(true)
				GlobalVariables.player_stopped = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.




extends "res://Scripts/player_script.gd"

@onready var seed = $"../seed"
@onready var skull = $"../skull"
@onready var rock = $"../rock"
@onready var egg = $"../egg"
@onready var soda = $"../soda"
@onready var apple = $"../apple"
@onready var butterfly = $"../butterfly"
@onready var carrot = $"../carrot"
@onready var cat = $"../cat"
@onready var lightbulb = $"../lightbulb"

# Monk
@onready var monk = $"../monk"
# Statues
@onready var tree_statue 		= $"../tree_statue"
@onready var hero_statue 		= $"../hero_statue"
@onready var geyser_statue 		= $"../geyser_statue"
@onready var dinosaur_statue 	= $"../dinosaur_statue"
@onready var rocket_statue 		= $"../rocket_statue"
@onready var apple_statue 		= $"../apple_statue"
@onready var butterfly_statue 	= $"../butterfly_statue"
@onready var turtle_statue 		= $"../turtle_statue"
@onready var cat_statue 		= $"../cat_statue"
@onready var electric_statue 	= $"../electric_statue"
@onready var plooy_statue 		= $"../plooy_statue"

var broken = false

func _on_player_finished_moving() -> void:
	if plooy_statue.plooy_in_statue and not broken:
		if seed.matched and skull.matched and rock.matched and egg.matched and soda.matched and apple.matched and butterfly.matched and carrot.matched and cat.matched and lightbulb.matched:
#			Play Cutscene 
			
#			Stop player
			set_process_input(false)
			
#			Cinematic Camera 

			get_node("Camera2D").emit_signal("cam_zoom", 1.5)
			get_node("Camera2D").emit_signal("reveal_bars")
			
#			Destroy individually each statues
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", tree_statue.global_position)
			tree_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", hero_statue.global_position)
			hero_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", geyser_statue.global_position)
			geyser_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", dinosaur_statue.global_position)
			dinosaur_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", rocket_statue.global_position)
			rocket_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", apple_statue.global_position)
			apple_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", butterfly_statue.global_position)
			butterfly_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", turtle_statue.global_position)
			turtle_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", cat_statue.global_position)
			cat_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", electric_statue.global_position)
			electric_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", plooy_statue.global_position)
			plooy_statue.get_node("AnimatedSprite2D").play("default")
			
			await get_tree().create_timer(0.75).timeout
			get_node("Camera2D").emit_signal("pan_to_pos", monk.global_position)
			await get_tree().create_timer(0.75).timeout
			monk.get_node("AnimatedSprite2D").play("reveal")
			
			var bg = get_parent().get_parent().get_parent().get_node("CanvasLayer").get_node("game_scene_bg")
			
			get_parent().toggle_grayscale(bg)
			get_parent().toggle_grayscale(area_handler.map_sprite)
			bg.play()
			
			await monk.get_node("AnimatedSprite2D").animation_finished
			await get_tree().create_timer(0.75).timeout
			
			broken = true
			level_handler.complete_current_level(get_parent().get_parent())
			

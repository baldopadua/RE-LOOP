extends object_class

@warning_ignore("unused_signal")
signal start_race()
@warning_ignore("unused_signal")
signal race_finished()

@onready var animated_sprite = $AnimatedSprite2D
@onready var hare = $"../Hare"
@onready var turtle = $"../Turtle"
@onready var player = $"../PlayerScene"
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var area_handler = get_parent().get_node("AreaHandler")
var turtle_won := false
var hare_won := false

# Keystones
@onready var carrot = $"../Small Carrot"
@onready var chair = $"../Chair"
@onready var tree = $"../Tree"
@onready var finish = $"../Finish Line"

# When picked-up by the player, start race

func move_turtle():
	turtle.emit_signal("rotate_object", GlobalVariables.Directions.COUNTERCLOCKWISE)

func move_hare():
	hare.emit_signal("rotate_object", GlobalVariables.Directions.COUNTERCLOCKWISE)

func _on_start_race() -> void:
	while true:

		if not finish.array.is_empty():
			if finish.array.front() == hare:
				hare_won = true
				turtle.animated_sprite.play("cry")
				hare.animated_sprite.play("winner_hare")
				break
			elif finish.array.front() == turtle:
	#			 Loop BREAK
				turtle_won = true
				turtle.animated_sprite.play("celebrates")
				hare.animated_sprite.play("loser_hare")

				if sound_manager:
					if sound_manager.sfx.has("sword"):
						sound_manager.play_sfx("sword")

					if sound_manager.has_method("play_finish_level_sfx"):
						sound_manager.play_finish_level_sfx()

				if area_handler:
					area_handler.show_loop_break(8)

				break

#		Priority hare reaches finish first
		if finish in hare.array:
			hare_won = true
			turtle.animated_sprite.play("cry")
			hare.animated_sprite.play("winner_hare")
			break

#		object branches
		if carrot in hare.array:
			await _process_carrot()
		elif chair in hare.array:
			await process_chair()
		elif tree in hare.array:
			await process_tree()
		else:
			await process_normal_movement()

		# small pacing delay (optional)
		await get_tree().create_timer(0.5).timeout
		
#	After breaking loop emit face rinished	
	race_finished.emit()
	
func _process_carrot() -> void:
	carrot.visible = false
	hare.animated_sprite.play("eating_carrot")
	await hare.animated_sprite.animation_finished

	move_turtle()
	await get_tree().create_timer(1.0).timeout
	move_turtle()
	await get_tree().create_timer(1.0).timeout

	hare.animated_sprite.play("surprised")
	await hare.animated_sprite.animation_finished
	hare.animated_sprite.play("default")

	hare.array.erase(carrot)

func process_chair():
	hare.visible = false
	chair.get_node("AnimatedSprite2D").play("sleeping")
	await chair.get_node("AnimatedSprite2D").animation_finished

	hare.visible = true
	chair.get_node("AnimatedSprite2D").play("default")
	move_turtle()
	await get_tree().create_timer(1.0).timeout
	move_turtle()
	await get_tree().create_timer(1.0).timeout

	hare.animated_sprite.play("surprised")
	await hare.animated_sprite.animation_finished
	hare.animated_sprite.play("default")

	hare.array.erase(chair)



func process_tree():
	tree.animated_sprite.play("window")
	hare.animated_sprite.play("find_wife")
	await hare.animated_sprite.animation_finished

#	Move tortol only once whenever it passes the tree unlike other objects, idk why
	move_turtle()
	await get_tree().create_timer(1.0).timeout

	hare.animated_sprite.play("surprised")
	await hare.animated_sprite.animation_finished
	hare.animated_sprite.play("default")

	hare.array.erase(tree)

func process_normal_movement():
#	hare moves
	move_hare()
	await get_tree().create_timer(1.0).timeout

	# re-check for objects before second move
	if carrot in hare.array or chair in hare.array or tree in hare.array:
		return

	if finish in hare.array:
		return  # winner logic will run next loop

	# second hare move
	move_hare()
	await get_tree().create_timer(1.0).timeout

	# then turtle moves
	move_turtle()
	await get_tree().create_timer(1.0).timeout

	hare.animated_sprite.play("default")

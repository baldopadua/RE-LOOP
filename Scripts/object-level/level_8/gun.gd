extends object_class

@warning_ignore("unused_signal")
signal start_race()
@warning_ignore("unused_signal")
signal race_finished()

@onready var animated_sprite = $AnimatedSprite2D
@onready var hare = $"../Hare"
@onready var turtle = $"../Turtle"
@onready var player = $"../PlayerScene"
var turtle_won : bool = false

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
	# Stop player
	# Cinematic Cameras all around
	
	# Rabbit moves first 2 moves per session and 1 if there is a keystoned
	
	GlobalVariables.player_stopped = true
	
	while round(hare.rotation_degrees) > -270.0 and round(turtle.rotation_degrees) > -270.0:
		if carrot in hare.array:
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
		elif chair in hare.array:
			hare.animated_sprite.play("resting_in_chair")
			await hare.animated_sprite.animation_finished
			move_turtle()
			await get_tree().create_timer(1.0).timeout
			move_turtle()
			await get_tree().create_timer(1.0).timeout
			hare.animated_sprite.play("surprised")
			await hare.animated_sprite.animation_finished
			hare.animated_sprite.play("default")
			hare.array.erase(chair)
		elif tree in hare.array:
			hare.animated_sprite.play("find_wife")
			await hare.animated_sprite.animation_finished
			move_turtle()
			await get_tree().create_timer(1.0).timeout
			hare.animated_sprite.play("surprised")
			await hare.animated_sprite.animation_finished
			hare.animated_sprite.play("default")
			hare.array.erase(tree)
		else:
			move_hare()
			await get_tree().create_timer(1.0).timeout
			if carrot in hare.array or chair in hare.array or tree in hare.array:
				continue
			if finish not in hare.array:
				move_hare()
				await get_tree().create_timer(1.0).timeout
				hare.animated_sprite.play("default")
				move_turtle()
				await get_tree().create_timer(1.0).timeout

		# Wait a bit before next cycle (optional)
		await get_tree().create_timer(1.0).timeout

		# Break condition (prevent infinite loop)
		if round(turtle.rotation_degrees) <= -270.0:
			turtle_won = true
			turtle.animated_sprite.play("celebrates")
			hare.animated_sprite.play("loser_hare")
			break
		elif round(hare.rotation_degrees) <= -270.0:
			turtle.animated_sprite.play("cry")
			hare.animated_sprite.play("winner_hare")
			break		
		
	race_finished.emit()

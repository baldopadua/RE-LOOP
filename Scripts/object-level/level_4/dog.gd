extends object_class

var is_played: bool = false
@onready var sprite = $StickDog
@onready var player = $"../PlayerScene"
var previous_state = current_state

func _process(_delta: float) -> void:
	if current_state != previous_state:
		match [previous_state, current_state, player.direction]:
			# Forward animations
			[2, 3, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = true
				sprite.play("old_to_grave")
				await sprite.animation_finished

			[1, 2, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = false

			# Reverse animations
			[3, 2, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = false
				sprite.play_backwards("old_to_grave")

			[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = false
				sprite.play_backwards("young_to_old")

			[3, 2, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = false
				sprite.play("old_to_grave")
				is_pickupable = false

			[2, 3, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = true
				sprite.play_backwards("old_to_grave")
				await sprite.animation_finished

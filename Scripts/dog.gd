extends object_class

var is_played: bool = false
@onready var stick_dog = $StickDog
@onready var bone_dog = $BoneDog
@onready var player = $"../PlayerScene"
var previous_state = current_state

func _process(_delta: float) -> void:
	if current_state != previous_state and has_node("stick"):
		swap_bone_to_stick(stick_dog)
	elif current_state != previous_state and !has_node("stick"):
		swap_bone_to_stick(bone_dog)
		
		
func swap_bone_to_stick(dog_anim):
	match [previous_state, current_state, player.direction]:
		# Forward animations
		[2, 3, GlobalVariables.player_direction.CLOCKWISE]:
			is_played = true
			dog_anim.play("old_to_grave")
			await dog_anim.animation_finished

		[1, 2, GlobalVariables.player_direction.CLOCKWISE]:
			is_played = false

		# Reverse animations
		[3, 2, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
			is_played = false
			dog_anim.play_backwards("old_to_grave")

		[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
			is_played = false
			dog_anim.play_backwards("young_to_old")

		[3, 2, GlobalVariables.player_direction.CLOCKWISE]:
			is_played = false
			dog_anim.play("old_to_grave")
			is_pickupable = false

		[2, 3, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
			is_played = true
			dog_anim.play_backwards("old_to_grave")
			await dog_anim.animation_finished
	previous_state = current_state

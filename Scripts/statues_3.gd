extends object_class

var is_played: bool = false
@onready var sprite = $AnimatedSprite2D
@onready var player = $"../PlayerScene"
var previous_state = current_state

func _process(_delta: float) -> void:
	if current_state != previous_state:
		match [previous_state, current_state, player.direction]:
			# Forward animations
			[2, 3, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = true
				sprite.play("rubble")
				await sprite.animation_finished
				is_pickupable = true

			[1, 2, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = false
				sprite.play("break")
				is_pickupable = false

			# Reverse animations
			[3, 2, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = false
				sprite.play_backwards("rubble")
				is_pickupable = false

			[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = false
				sprite.play_backwards("break")
				is_pickupable = false

			[3, 2, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = false
				sprite.play("rubble")
				is_pickupable = false

			[2, 3, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = true
				sprite.play_backwards("rubble")
				await sprite.animation_finished
				is_pickupable = true
	previous_state = current_state
	
func interact(object_interacted: object_class):
	if object_interacted.object_name == "incubator":
		position = Vector2(0, 50.0)
		reparent(object_interacted)
		is_pickupable = false
		visible = false

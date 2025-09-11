extends object_class

var is_played: bool = false
@onready var dirt = $DirtSprite
@onready var branch = $branch
@onready var player = $"../PlayerScene"
@onready var stick = $stick
var previous_state = current_state

func _process(_delta: float) -> void:
	if current_state != previous_state and has_node("seed"):
		match [previous_state, current_state, player.direction]:
			[1, 2, GlobalVariables.player_direction.CLOCKWISE]:
				is_played = false
				if stick:
					branch.play("tree")
					await branch.animation_finished
					stick.visible = true
					stick.is_pickupable = true
					branch.visible = false
				else:
					branch.visible = false
			[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				is_played = false
				if stick:
					stick.visible = false
					branch.visible = true
					stick.is_pickupable = false
					branch.play_backwards("tree")
				else:
					branch.visible = false

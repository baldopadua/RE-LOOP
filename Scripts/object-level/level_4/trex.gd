extends object_class

# If incubator is not complete, trex is not processed
var is_processed : bool = false
var previous_state = current_state
@onready var player = $"../PlayerScene"
@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $"../AnimationPlayer"

func _process(_delta: float) -> void:
	if is_processed and (current_state != previous_state):
		match [previous_state, current_state, player.direction]:
			# Forward animations
			[1, 2, GlobalVariables.player_direction.CLOCKWISE]:
				sprite.play("egg_to_trex")
				await sprite.animation_finished
			
			[2, 2, GlobalVariables.player_direction.CLOCKWISE]:
				sprite.play("egg_to_trex")
				await sprite.animation_finished

			# Reverse animations
			[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				sprite.play_backwards("egg_to_trex")
				await sprite.animation_finished
	previous_state = current_state

func _on_body_entered(body):
	if body.name != "PlayerScene" or not is_processed:
		return
	
	handle_body_entered(body)
	
	GlobalVariables.is_looping = false
	GlobalVariables.player_stopped = true
	
	sprite.play("tail_whip")
	await sprite.animation_finished
	
	anim_player.play("tail_whipped")

extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions
const transition_time: float = 0.5
var is_looping: bool = false
var player_stopped: bool = false

func play_sfx(sfx: Object, direction: Directions):
	if direction == player_direction.CLOCKWISE:
		sfx.pitch_scale += 0.05
		sfx.play()
	else:
		sfx.pitch_scale -= 0.05
		sfx.play()

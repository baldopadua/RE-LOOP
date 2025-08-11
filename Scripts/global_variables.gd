extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions

const transition_time: float = 0.1
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false

func play_sfx(sfx: Object, direction: Directions):
	if direction == player_direction.CLOCKWISE:
		sfx.pitch_scale += 0.03
		sfx.play()
	else:
		sfx.pitch_scale -= 0.03
		sfx.play()

func restart_level_sfx_vfx(sfxs: Array):
	# PERFORM SOME CUTSCENES AFTER RESTARTING
	# SFX
	for sfx in sfxs:
		sfx.play()

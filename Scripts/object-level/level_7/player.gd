extends "res://Scripts/player_script.gd"

# on rotate 

@onready var butterfly = $"../butterfly"

func _on_player_finished_moving() -> void:

	var prev_state = butterfly.b_curr_state

	if butterfly.moves == 3:
		butterfly.emit_signal("add_state", direction)

	# If butterfly was not yet fully transformed before this move, stop here
	if prev_state < 3:
		return

	# Only rotate if already in butterfly form
	if direction == GlobalVariables.Directions.CLOCKWISE and butterfly.b_curr_state == 3:
		butterfly.emit_signal("rotate_object", GlobalVariables.Directions.CLOCKWISE)
	elif direction == GlobalVariables.Directions.COUNTERCLOCKWISE and butterfly.b_curr_state == 3:
		butterfly.emit_signal("rotate_object", GlobalVariables.Directions.COUNTERCLOCKWISE)

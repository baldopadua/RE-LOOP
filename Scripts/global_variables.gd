extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions
enum object_types {TOOL, NONTOOL, DECORATIVE}

const transition_time: float = 0.25 # 0.25 Default
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false
var player_moves: int = 0  # Track player moves globally

# Reset player moves (called when level restarts)
func reset_player_moves() -> void:
	player_moves = 0

# Extract level number from object names like "level_1_entrance", "level_2_door", etc.
func get_level_number_from_name(object_name: String) -> int:
	# Look for pattern "level_X" where X is a number
	var regex = RegEx.new()
	regex.compile("level_(\\d+)")
	var result = regex.search(object_name)
	
	if result:
		return result.get_string(1).to_int()
	
	return 0  # Return 0 if no level number found

# returns true if the node has a signal with the passed name
func hasSignal(node : Node, signalName : String) -> bool:
	var signalList = node.get_signal_list()
	for signalDictionary in signalList:
		if signalDictionary.name == signalName:
			return true
	return false

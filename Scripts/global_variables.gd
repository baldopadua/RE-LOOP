extends Node

enum Directions {COUNTERCLOCKWISE, CLOCKWISE}
const player_direction = Directions
enum object_types {TOOL, NONTOOL}

const transition_time: float = 0.1 # 0.25 Default
var is_looping: bool = false
var player_stopped: bool = false
var is_restarting: bool = false

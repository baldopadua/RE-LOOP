extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/game_scene_bg.position = get_viewport_rect().size / 2
	$CanvasLayer/game_scene_bg.play() 
	
	# TODO: Temporarily Disable Level Lobby for debugging
	$levels_frame/LevelLobby.process_mode = 4

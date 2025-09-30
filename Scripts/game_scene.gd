extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Fix background position to viewport center and ensure it stays there
	var viewport_center = get_viewport_rect().size / 2
	$CanvasLayer/game_scene_bg.position = viewport_center
	$CanvasLayer/game_scene_bg.play()
	
	# Ensure background stays centered even during level transitions
	get_viewport().size_changed.connect(_on_viewport_size_changed)

# Keep background centered when viewport changes
func _on_viewport_size_changed():
	if $CanvasLayer/game_scene_bg:
		$CanvasLayer/game_scene_bg.position = get_viewport_rect().size / 2

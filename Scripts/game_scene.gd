extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/game_scene_bg.position = get_viewport_rect().size / 2
	$CanvasLayer/game_scene_bg.play() 
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

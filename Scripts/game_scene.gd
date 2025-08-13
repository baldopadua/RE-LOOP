extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $game_scene_bgm:
		$game_scene_bgm.play()
	$CanvasLayer/game_scene_bg.play() 
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

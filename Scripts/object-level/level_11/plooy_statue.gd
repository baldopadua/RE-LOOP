extends object_class

var plooy_in_statue = false
@onready var player = $"../PlayerScene"

func _on_body_entered(body) -> void:
	handle_body_entered(body)
	plooy_in_statue = true
	player.emit_signal("player_finished_moving")
	
func _on_body_exited(body) -> void:
	handle_body_exited(body)
	plooy_in_statue = false

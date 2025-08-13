extends object_class

var is_played: bool = false
@onready var sprite = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if current_state == 2 and not is_played:
		is_played = true
		sprite.play("Present")
		await sprite.animation_finished
		is_pickupable = true
	elif current_state == 1 and is_played:
		is_played = false
		sprite.play("Past")
	elif current_state == 3 and is_played:
		is_played = false
		sprite.play("Future")
		
func interact(object_interacted: object_class):
	if object_interacted.object_name == "incubator":
		position = Vector2(0, 50.0)
		reparent(object_interacted)
		is_pickupable = false
		visible = false

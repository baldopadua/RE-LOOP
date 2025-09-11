extends object_class

@export var orig_pos: Vector2
@export var orig_rotation: float
@onready var sound_manager = get_parent().get_node("SoundManager")

func interact(object_interacted: object_class):
	if object_interacted.object_name == "geyser":
		# PUT ON ROCKS ARRAY
		object_interacted.rocks.append(self)
		
		# PUT DOWN THE POSITION
		# TWEEN TO ADD BOUNCE WHEN DROPPING DOWN
		var tween_drop = create_tween()
		
		# POSITION DROP
		var pos_drop = Vector2(0, 50.0)
		
		tween_drop.tween_property(self, "position", pos_drop, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await tween_drop.finished
		tween_drop.kill()
		
		if sound_manager:
			sound_manager.play_sfx("rock_water_drop")
		
		reparent(object_interacted)
		is_pickupable = false
		visible = false

		# IF VISIBLE SET TO FALSE
		#if object_interacted.get_node("NoRock").visible:
			#object_interacted.get_node("NoRock").visible = false

		# CHECK EVERY STATES IN GEYSER
		for node in object_interacted.get_children():
			# IF NODE IS STATE AND STATE NUM IS SIZE OF ROCK
			if "State" in str(node.name) and str(object_interacted.rocks.size()) in str(node.name):
				#print("STATE IN NAME")
				node.visible = true
				break

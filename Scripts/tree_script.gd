extends object_class

func _on_body_entered(body) -> void:
	#print("BODY: %s" % str(body))
	if body.name != "PlayerScene":
		return
	# For Tools [ Mop, Rugs, Buckets ]
	if is_pickupable and not body.is_holding_object:
		print("Player can pick up %s" % object_name)
		is_reachable = true
		player_char = body
		body.available_object = self
	# For Interactables [ Puddles, Drips, Toilet ]
	elif not is_pickupable and body.is_holding_object:
		print("%s is interactable" % object_name)
		is_reachable = true
		player_char = body
		#body.available_interactable_object = self
		body.interactable_objects.append(self)
		print(body.interactable_objects)
	
	# CLIMB THE TREE
	if not GlobalVariables.is_looping:
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		# CLIMB
		for i in range(1,300):
			await get_tree().create_timer(0.01).timeout
			body.position += Vector2(0,1)
		body.visible = false
		# SWITCH SCENE TO LEVEL 2

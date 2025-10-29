extends object_class

# Use signals to determine if all three keystones are in order
# If time_forwarded, the laser gets activated and shots a laser into the middle

# SIGNALS
@warning_ignore("unused_signal")
signal keystone_complete(obj, enabled)

# KEYSTONE BOOLEAN SWITCHES
var did_nicola_successfully_invented_tesla: bool = false
var did_edison_successfully_invented_bulb: bool = false
var did_franklin_successfully_invented_electricity: bool = false

# MY ANIMATED SPRITE
@onready var animated_sprite = $AnimatedSprite2D

# ENABLE PROCEEDING IN DIFFERENT LEVEL

func _on_keystone_complete(obj: object_class, enabled) -> void:
	if obj.object_name == "tesla_coil":
		if enabled: did_nicola_successfully_invented_tesla = true
		else: did_nicola_successfully_invented_tesla = false
	elif obj.object_name == "light_bulb":
		if enabled: did_edison_successfully_invented_bulb = true
		else: did_edison_successfully_invented_bulb = false
	elif obj.object_name == "lightning_cloud":
		if enabled: did_franklin_successfully_invented_electricity = true
		else: did_franklin_successfully_invented_electricity = false	
	
	# IF ALL KEYSTONE ARE COMPLETE
	if did_nicola_successfully_invented_tesla and did_edison_successfully_invented_bulb and did_franklin_successfully_invented_electricity:
		animated_sprite.play("laser_fire")
		animated_sprite.animation_finished.connect(func():
			# DO SOMETHING HERE
			# STOP PLOOY MOVEMENT
			GlobalVariables.player_stopped = true
			# PLAY CAMERA CUTSCENE
			
			# PLAY SFX
			
			# ENABLE BODY ENTERED OR SOMETHING THAT WILL GO TO THE NEXT LEVEL
			
			# ENABLE PLOOY MOVEMENT
			GlobalVariables.player_stopped = false
			GlobalVariables.is_looping = false
			pass	
		)

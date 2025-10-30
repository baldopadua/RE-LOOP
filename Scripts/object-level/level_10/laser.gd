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

func _on_keystone_complete(obj_name: String, enabled: bool) -> void:
	if obj_name == "nicola_tesla":
		did_nicola_successfully_invented_tesla = enabled
	elif obj_name == "thomas_edison":
		did_edison_successfully_invented_bulb = enabled
	elif obj_name == "benjamin_franklin":
		did_franklin_successfully_invented_electricity = enabled	
	
	print("KEYSTONE SWITCHES: ", did_nicola_successfully_invented_tesla, " ", did_edison_successfully_invented_bulb, " ", did_franklin_successfully_invented_electricity)
	
	# IF ALL KEYSTONE ARE COMPLETE
	if did_nicola_successfully_invented_tesla and did_edison_successfully_invented_bulb and did_franklin_successfully_invented_electricity:
		animated_sprite.play("laser_fire")
		# STOP PLOOY MOVEMENT
		GlobalVariables.player_stopped = true
		animated_sprite.animation_finished.connect(func():
			# DO SOMETHING HERE
			
			
			# PLAY CAMERA CUTSCENE
			
			# PLAY SFX
			
			# ENABLE BODY ENTERED OR SOMETHING THAT WILL GO TO THE NEXT LEVEL
			
			# ENABLE PLOOY MOVEMENT
			GlobalVariables.player_stopped = false
			GlobalVariables.is_looping = false
			pass	
		)

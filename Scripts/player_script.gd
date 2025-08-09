extends CharacterBody2D

const SPEED = 300.0
const ROTATION_SPEED = 5.0
const RAYCAST_LENGTH = 20.0

@onready var player_sprite = $Sprite2D
@onready var feet_marker = $FeetGroundMarker
var is_grounded = false
var surface_normal = Vector2.UP
var target_rotation = 0.0

func _physics_process(delta: float) -> void:
	# Surface-following movement with feet marker
	check_ground_contact()
	
	# Handle movement input
	var direction := 0.0
	if Input.is_key_pressed(KEY_A):
		direction += 1.0
	if Input.is_key_pressed(KEY_D):
		direction -= 1.0
	
	if is_grounded:
		# Move along surface
		if direction != 0:
			var tangent = Vector2(surface_normal.y, -surface_normal.x)
			velocity = tangent * direction * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 3)
		
		# Rotate character to align with surface
		target_rotation = surface_normal.angle() + PI/2
		rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta)
		
		# Stick feet to surface
		stick_to_surface()
	else:
		# Free fall with basic physics when airborne
		velocity += Vector2.DOWN * 980.0 * delta
		if direction != 0:
			velocity.x += direction * SPEED * delta * 0.8
			velocity.x = clamp(velocity.x, -SPEED * 1.2, SPEED * 1.2)
		
		target_rotation = 0.0
		rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta * 0.5)

	# Always use default animation
	if player_sprite.animation != "default":
		player_sprite.animation = "default"

	move_and_slide()
	
	# Flip sprite based on direction
	if velocity.x > 0:
		player_sprite.flip_h = false
	elif velocity.x < 0:
		player_sprite.flip_h = true

func check_ground_contact():
	var space_state = get_world_2d().direct_space_state
	var feet_global_pos = global_position + feet_marker.position.rotated(rotation)
	
	var query = PhysicsRayQueryParameters2D.create(
		feet_global_pos,
		feet_global_pos + Vector2.DOWN.rotated(rotation) * RAYCAST_LENGTH
	)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		is_grounded = true
		surface_normal = result.normal
		# Store the contact point for sticking
		var contact_point = result.position
		var offset_to_feet = feet_global_pos - global_position
		global_position = contact_point - offset_to_feet
	else:
		is_grounded = false
		surface_normal = Vector2.UP

func stick_to_surface():
	# Additional raycast to ensure feet stay on surface
	var space_state = get_world_2d().direct_space_state
	var feet_global_pos = global_position + feet_marker.position.rotated(rotation)
	
	var query = PhysicsRayQueryParameters2D.create(
		feet_global_pos - surface_normal * 5,
		feet_global_pos + surface_normal * 10
	)
	
	var result = space_state.intersect_ray(query)
	if result:
		var contact_point = result.position
		var offset_to_feet = feet_marker.position.rotated(rotation)
		var target_position = contact_point - offset_to_feet
		
		# Limit how far we can move the character to prevent teleporting
		var max_correction_distance = 5.0
		var distance_to_target = global_position.distance_to(target_position)
		
		if distance_to_target <= max_correction_distance:
			# Smooth the position correction instead of instant teleport
			global_position = global_position.lerp(target_position, 0.5)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	pass

func _on_area_2d_area_exited(_area: Area2D) -> void:
	pass

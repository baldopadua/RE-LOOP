extends Area2D
class_name object_class

# OBJECTS can be
# 1. Picked Up
# 2. Throwables
# 3. Tools

@export var object_name: String = "Generic Object"
@export var is_pickupable: bool = true
@export var usable_targets: Array[String] = [] 

var is_reachable: bool = false
var player_char: CharacterBody2D = null
var player_arrow_owner: CharacterBody2D

func _ready():
	print(object_name + " instantiated!")

# Tinanggal ko muna ung static type ng body, but it should be CharacterBody2D
# Nag e-error kasi kapag naka staticly typed ewan pa kung bakit
# Both body_entered tsaka body_exit ko tinanggal

func _on_body_entered(body) -> void:
	print("BODY: %s" % str(body))
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
		body.available_interactable_object = self

func _on_body_exited(body) -> void:
	print("BODY: %s" % str(body))
	if body != player_char:
		return
	
	# Tool behavior if out of rangea
	if is_pickupable:
		is_reachable = false
		player_char = null
		body.available_object = null
		print("Out of Object Range")
		
	# Interatable behavior if out of range
	if not is_pickupable:
		is_reachable = false
		player_char = null
		body.available_interactable_object = null
		print("Out of Interactable Range")

func set_flipped(flip: bool):
	if has_node("item_sprite"):   
		$item_sprite.flip_h = flip

#Interaction with problems
func use_on(target: object_class) -> bool:
	if target == null:
		return false
	if target.has_method("get_obj_name"):
		var target_name = target.get_obj_name()
		if target_name in usable_targets:
			print("%s used on %s" % [object_name, target_name])
			return true
	return false
	
func get_obj_name():
	return object_name

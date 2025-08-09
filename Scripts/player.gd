extends CharacterBody2D

@onready var player_sprite = $sprite
@onready var score_gd: Control = $CanvasLayer/ScoreUi
@export var movement_speed : float = 500

var is_holding_object : bool = false
var character_direction : Vector2
var available_object : object_class = null
var held_object: object_class = null
var drop_pos: Vector2
var object_pos: Marker2D = null
var origi_object_pos: Vector2
var available_interactable_object : object_class = null
var can_move: bool = true

func _ready():
	object_pos = get_node("object_position")
	origi_object_pos = object_pos.position 
	


func _input(event: InputEvent):
	# Pick Up Objects
	if event.is_action_pressed("interact") and available_object != null:
		item_pick_up()
	# Drop Objects
	elif event.is_action_pressed("drop") and is_holding_object:
		item_drop()
	# Interact with Objects using Tools
	# TODO: Guys baka meron kayo mas efficient solution, may apo na sa tuhod yung if else ko ;-;
	elif event.is_action_pressed("interact") and is_holding_object and available_interactable_object != null :
		var success = held_object.use_on(available_interactable_object)
		if success:
			print("%s Successfully Used" % held_object.object_name)
			if available_interactable_object.has_method("interact"):
				var task_finished: bool = await available_interactable_object.interact(self)
				if task_finished:
					if score_gd != null and score_gd.has_method("add_score") and available_interactable_object.score_if_cleared > 0:
						score_gd.add_score(available_interactable_object.score_if_cleared)
		else:
			print("Failed to use %s" % held_object.object_name)

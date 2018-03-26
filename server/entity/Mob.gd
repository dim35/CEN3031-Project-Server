extends "res://server/entity/entity.gd"

onready var world = get_node("/root/World")
onready var players = get_node("/root/World/entities/players")
func _ready():
	who = "mob"
	print ("created mob")
	
var speed = 100
func find_nearest_player():
	var minx = 5000
	var near = null
	for p in world.player_pos:
		var x = position.distance_to(world.player_pos[p])
		if (x < minx):
			minx = x
			near = p
	return near

func move():
	position.y = 460
	var player = find_nearest_player()
	if (player != null):
		velocity.x = (2 * int(world.player_pos[player] > position) - 1)* speed
	move_and_slide(velocity, Vector2(0,-1))
	rpc("remote_move", position)
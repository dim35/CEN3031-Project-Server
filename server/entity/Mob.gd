extends "res://server/entity/entity.gd"

onready var world = get_node("/root/World")
onready var players = get_node("/root/World/entities/players")

func _ready():
	health = 100
	who = "mob"
	var hitbox = CollisionShape2D.new()
	hitbox.set_shape(load("res://server/entity/entity_resources/mob_hitbox.tres"))
	add_child(hitbox)
	
var speed = 100
func find_nearest_player():
	var minx = 5000
	var near = null
	for p in players.get_children():
		var x = position.distance_to(p.position)
		if (x < minx):
			minx = x
			near = p
	return near

func move():
	if !is_on_floor():
		velocity.y += 12
	var player = find_nearest_player()
	if (player != null):
		velocity.x = (2 * int(player.position.x > position.x) - 1)* speed
		
	if (test_move(transform, Vector2(1, 0)) or test_move(transform, Vector2(-1, 0)) and is_on_floor()):
		velocity.y += -24
	move_and_slide(velocity, Vector2(0,-1))
	rpc("remote_move", position, velocity)
	
remote func take_damage(x):
	health -= x
	rpc("set_health", health)
	if (health < 0):
		rpc("delete")
		queue_free()
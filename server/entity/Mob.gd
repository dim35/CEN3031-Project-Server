extends "res://server/entity/entity.gd"

onready var world = get_node("/root/World")
onready var players = get_node("/root/World/entities/players")

func _ready():
	health = 100
	speed = 100
	who = "mob"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/mob_hitbox.tres"))
	set_collision_layer_bit(Base.MOB_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles
	
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
		rpc("delete_me")
		queue_free()
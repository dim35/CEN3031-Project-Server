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
	#set mob position
	var index = randi()%world.get_node("Spawning/MobSpawnPoints").get_child_count()
	position = world.get_node("Spawning/MobSpawnPoints").get_child(index).get_global_position()
	get_node("area").connect("body_entered", self, "_on_area_body_entered")
	
func _on_area_body_entered(body):
	if body.is_class("TileMap"):
		velocity.y = -1.5*150
	
func find_nearest_player():
	var minx = 200
	var near = null
	for p in players.get_children():
		var x = position.distance_to(p.position)
		if (x < minx):
			minx = x
			near = p
	return near

func move():
	var player = find_nearest_player()
	if (player != null):
		velocity.x = (2 * int(player.position.x > position.x) - 1)* speed
	move_and_slide(velocity, Vector2(0,-1))
	rpc("remote_move", position, velocity)
	if !is_on_floor():
		velocity.y += 12
	
remote func take_damage(x):
	health -= x
	rpc("set_health", health)
	if (health <= 0):
		world.get_node("Spawning/ItemSpawner").spawn_item(position, 0) # spawn a potion
		rpc("delete_me")
		queue_free()
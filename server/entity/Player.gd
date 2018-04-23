extends "res://server/entity/entity.gd"

var username
var classtype
var ready = false

var inventory = Dictionary()

var w = null
var old_pos = false

var cloest_mob_spawnpoints = []

func _ready():
	w = get_tree().get_root().get_node("World")
	who = "player"
	ready = false
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	get_node("area/collision").set_shape(load("res://server/entity/entity_resources/PlayerAreaDetector.tres"))
	#Spawn at start if beginning of game or if one player present
	if (w.get_node("entities/players").get_child_count() == 1 || !w.get_node("Spawning/PlayerSpawner").respawn) and !old_pos:
		position = w.get_node("Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
	#Respawn on teammates if available
	elif w.get_node("entities/players").get_child_count() != 1 and w.get_node("Spawning/PlayerSpawner").respawn and !old_pos:
		var index = randi()%w.get_node("entities/players").get_child_count()
		position = w.get_node("entities/players").get_child(index).get_global_position()
	else:
		old_pos = false
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	set_collision_mask_bit(Base.ITEM_COLLISION_LAYER, true) # players
	get_node("area").connect("body_entered", self, "_on_area_body_entered")
	get_node("area").connect("body_exited", self, "_on_area_body_exited")
	
	
var last_direction = 0
var is_attacking
remote func move(v, is_atk):
	if v.y < 0:
		if !(is_on_floor() or test_move(transform, Vector2(0,5))):
			v.y = 0
	velocity += v
	is_attacking = is_atk
	var new_anim = "idle"
	if (velocity.x != 0):
		last_direction = velocity.x < 0
	if (is_attacking):
		new_anim = "attacking"
		attack()
	elif velocity.x != 0 and test_move(transform, Vector2(0,5)):
		new_anim = "walking"
	elif !test_move(transform, Vector2(0,5)):
		new_anim = "falling"
	
	state = new_anim
	
remote func set_to_idle():
	state = "idle"

func get_closest_mob_spawnpoints():
	var minx = 700
	var close = []
	for spawn in w.get_node("Spawning/MobSpawnPoints").get_children():
		var x = position.distance_to(spawn.position)
		if (x < minx):
			close.push_back(spawn)
	cloest_mob_spawnpoints = close

func _physics_process(delta):
	get_closest_mob_spawnpoints()
	# gravity update is server side
	if !test_move(transform, Vector2(0,5)):
		apply_gravity()
	elif velocity.y > 0:
		velocity.y = 0
	if(velocity.x != 0):
		last_direction = velocity.x < 0
	check_position()
	move_and_slide(velocity)
	if ready:
		rpc("remote_move", position, velocity, state, last_direction)
	# set velocity of x to zero after each time we move
	
	velocity.x = 0
	
	if (get_slide_count() > 0):
		for i in range(get_slide_count()):
			var kc2D = get_slide_collision(i)
			if kc2D.collider.is_class("TileMap"):
				continue
			match kc2D.collider.who:
				"item":
					kc2D.collider.picked_up(self)


#overrides func in entity.gd
func check_position():
	if position.y > 2000:
		rpc("playWilhelm")
		if w.get_node("entities/players").get_child_count() == 1:
			position = w.get_node("Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
		else:
			var index = randi()%w.get_node("entities/players").get_child_count()
			position = w.get_node("entities/players").get_child(index).get_global_position()
		velocity.y = 0
		
		health = MAX_HEALTH/2
		mana = MAX_MANA/2
		stamina = MAX_STAMINA/2
		
		for i in range(2):
			inventory[i] = 0
		w.update_inventory_to_client(self)
		
		rpc("set_health", health)
		rpc("set_mana", mana)
		rpc("set_stamina", stamina)


func give_client_stats():
	rpc_id(int(get_name()), "update_stats", health, mana, stamina, defense, speed, damage)
	
	
func _on_area_body_entered(body):
	if body.is_class("TileMap"):
		pass
	elif body.who == "mob":
		var minx = 50
		var x = position.distance_to(body.position)
		var A = position.x
		var B = position.x + -(2*int(last_direction)-1)*50
		var C = body.position.x
		if (x < minx and (abs(A-C) + abs(B-C) == abs(A-B))):
			enemies_in_range[body] = true	
	
	
func _on_area_body_exited(body):
	if body.is_class("TileMap"):
		pass
	elif body.who == "mob":
		enemies_in_range.erase(body)
	
	
func take_damage(x):
	health -= float(x)/defense
	rpc("set_health", health)
	if health <= 0:
		rpc("playDeath")
		if w.get_node("entities/players").get_child_count() == 1:
			position = w.get_node("Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
		else:
			var index = randi()%w.get_node("entities/players").get_child_count()
			position = w.get_node("entities/players").get_child(index).get_global_position()
		
		health = MAX_HEALTH/2
		mana = MAX_MANA/2
		stamina = MAX_STAMINA/2
		
		for i in range(2):
			inventory[i] = 0
		w.update_inventory_to_client(self)
		
		rpc("set_health", health)
		rpc("set_mana", mana)
		rpc("set_stamina", stamina)


remote func restore_stats(id):
	if id == 0:
		health = min(health + 60, MAX_HEALTH)	
		rpc("set_health", health)
	elif id == 1:
		stamina = MAX_STAMINA
		rpc("set_stamina", stamina)
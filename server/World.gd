extends Node

onready var global_player = get_node("/root/global_player")
onready var entity = load("res://server/entity/entity.gd")
onready var projectile = load("res://server/entity/Projectile.gd")

var projectiles = null
var items = null
var mobs = null
var players = null

var web_thread = Thread.new()
var spawn_player_thread = Thread.new()
var timer = 100

func _ready():
	#create container node of entities
	var n = Node.new()
	n.set_name("entities")
	
	#create container node of projectiles
	var proj = Node.new()
	proj.set_name("projectiles")
	n.add_child(proj)
	
	#create container nodes for items
	var i = Node.new()
	i.set_name("items")
	n.add_child(i)
	
	#create container node for mobs
	var m = Node.new()
	m.set_name("mobs")
	n.add_child(m)
	
	#create container node of players
	var p = Node.new()
	p.set_name("players")
	n.add_child(p)
	
	add_child(n)
	
	#reference variables
	projectiles = n.get_node("projectiles")
	items = n.get_node("items")
	mobs = n.get_node("mobs")
	players = n.get_node("players")
	
	$Spawning/PlayerSpawner.players = players
	$Spawning/ItemSpawner.items = items
	$Spawning/MobSpawner.mobs = mobs
	
	#spawn players
	#spawn_player_thread.start($Spawning/PlayerSpawner, "spawn_initial", 2) # feels bad man
	$Spawning/PlayerSpawner.spawn_initial(null)

func save_player_data(params):
	print("Saving player data")
	for p in players.get_children():
		global_player.set_data({"username":"daniel", "classtype":p.classtype,
										 "items":p.inventory, "health":p.health, "stamina":p.stamina, "mana":p.mana,
										 "posx":p.position.x, "posy":p.position.y})
	web_thread.wait_to_finish()

func _physics_process(delta):
	timer -= delta
	if (timer < 0 and not web_thread.is_active()):
		web_thread.start(self, "save_player_data")
		timer = 100
		
	#move projectiles
	for proj in projectiles.get_children():
		proj.move()


func spawn_fireball(p, dir, path):
	#mage attack projectile
	var new_proj = projectile.new()
	var id = randi()%10000000000 + 1 # <== Better hope we don't generate two of the same id
	new_proj.set_name(str(id))
	new_proj.position = p
	new_proj.direction = dir
	new_proj.big_boi_player = get_node(path)
	rpc("spawn", "projectile", id)
	projectiles.add_child(new_proj)


remote func feed_me_player_info(id):
	#spawn_player_thread.wait_to_finish()
	print ("Feeding player data to " + str(id))
	for id in global_player.player_info:
		rpc_id(id, "set_inventory", global_player.player_info[id]["data"]["items"])
	for p in players.get_children():
		rpc_id(id,"spawn", "player", p.get_name(), p.classtype, p.username)
		p.give_client_stats()


remote func mark_player_as_spawned(id):
	print ("Mark " + str(id) + " as spawned")
	for p in players.get_children():
		if p.get_name() == str(id):
			p.ready = true


remote func player_position(id, pos):
	$Spawning/PlayerSpawner.player_pos[id] = pos


remote func spawn_mob(who, id):
	rpc("spawn", who, id)


remote func item_drop(unique_id, id):
	rpc("spawn", "item", unique_id, id)
	
	
	
func update_inventory_to_client(player):
	rpc_id(int(player.get_name()), "set_inventory", player.inventory)
	
	
remote func update_inventory_from_client(id, inventory):
	players.get_node(str(id)).inventory = inventory
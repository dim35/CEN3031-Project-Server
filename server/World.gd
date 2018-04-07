extends Node

onready var entity = load("res://server/entity/entity.gd")
<<<<<<< HEAD
=======
onready var mob = load("res://server/entity/Mob.gd")

onready var player = load("res://server/entity/Player.gd")
onready var class_knight = load("res://server/entity/class_knight.gd")
onready var class_mage = load("res://server/entity/class_mage.gd")
onready var class_rogue = load("res://server/entity/class_rogue.gd")
>>>>>>> upstream/master
onready var projectile = load("res://server/entity/Projectile.gd")

var projectiles = null
var items = null
var mobs = null
var players = null

func _ready():
	#$Spawning/PlayerSpawner.global_player = global_player
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
	
<<<<<<< HEAD
	#spawn players
	$Spawning/PlayerSpawner.spawn_initial()


func _physics_process(delta):
	#move projectiles
	for proj in projectiles.get_children():
		proj.move()

=======
	for p in global_player.player_info:
		var ctype = global_player.player_info[p]["classtype"]
		var new_player = null
		if ctype == "Knight":
			new_player = class_knight.new()
		elif ctype == "Mage":
			new_player = class_mage.new()	
		elif ctype == "Rogue":
			new_player = class_rogue.new()		
		new_player.set_name(str(p))
		new_player.classtype = ctype
		#new_player.set_network_master(p)
		new_player.username = global_player.player_info[p]["username"]
		new_player.classtype = global_player.player_info[p]["classtype"]
		players.add_child(new_player)
		print("Spawned player")
>>>>>>> upstream/master

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
	print ("Feeding player data to " + str(id))
	for p in players.get_children():
		rpc_id(id,"spawn", "player", p.get_name(), p.classtype, p.username)


remote func mark_player_as_spawned(id):
	print ("Mark " + str(id) + " as spawned")
	for p in players.get_children():
		if p.get_name() == id:
			p.ready = true


remote func player_position(id, pos):
	$Spawning/PlayerSpawner.player_pos[id] = pos


remote func spawn_mob(who, id):
	rpc("spawn", who, id)


remote func item_drop(unique_id, id):
	rpc("spawn", "item", unique_id, id)
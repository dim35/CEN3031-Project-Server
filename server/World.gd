extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var global_player = get_node("/root/global_player")
onready var entity = load("res://server/entity/entity.gd")
onready var mob = load("res://server/entity/Mob.gd")

onready var player = load("res://server/entity/Player.gd")
onready var class_knight = load("res://server/entity/class_knight.gd")
onready var class_mage = load("res://server/entity/class_mage.gd")
onready var projectile = load("res://server/entity/Projectile.gd")
onready var item = load("res://server/entity/Item.gd")


var entities = null
var players = null
var mobs = null
var items = null
var projectiles = null

func _ready():
	# Create entites node
	var n = Node.new()
	n.set_name("entities")
	
	var p = Node.new()
	p.set_name("players")
	n.add_child(p)
	
	var m = Node.new()
	m.set_name("mobs")
	n.add_child(m)
	
	var i = Node.new()
	i.set_name("items")
	n.add_child(i)
	
	var proj = Node.new()
	proj.set_name("projectiles")
	n.add_child(proj)
	
	add_child(n)
	
	entities = get_node("/root/World/entities")
	players = get_node("/root/World/entities/players")
	mobs = get_node("/root/World/entities/mobs")
	items = get_node("/root/World/entities/items")
	projectiles = get_node("/root/World/entities/projectiles")
	

	get_node("/root/global_player").connect("player_disconnect", self, "player_disconnect")
	
	for p in global_player.player_info:
		var ctype = global_player.player_info[p]["classtype"]
		var new_player = null
		if ctype == "Knight":
			new_player = class_knight.new()
		elif ctype == "Mage":
			new_player = class_mage.new()			
		new_player.set_name(str(p))
		new_player.classtype = ctype
		#new_player.set_network_master(p)
		new_player.username = global_player.player_info[p]["username"]
		new_player.classtype = global_player.player_info[p]["classtype"]
		players.add_child(new_player)
		print("Spawned player")

func spawn_fireball(p, dir, path):
	var new_proj = projectile.new()
	var id = randi()%10000000000 + 1 # <== Better hope we don't generate two of the same id
	new_proj.set_name(str(id))
	new_proj.position = p
	new_proj.direction = dir
	new_proj.big_boi_player = get_node(path)
	rpc("spawn", "projectile", id)
	projectiles.add_child(new_proj)

func spawn_item(pos, id):
	var unique_id = randi()%10000000000 + 1 # <== Better hope we don't generate two of the same id	
	var new_item = item.new()
	new_item.set_name(str(unique_id))
	new_item.position = pos
	new_item.id = id
	rpc("spawn", "item", unique_id, id)
	items.add_child(new_item)
	

remote func feed_me_player_info(id):
	print ("Feeding player data to " + str(id))
	for p in players.get_children():
		rpc_id(id,"spawn", "player", p.get_name(), p.classtype)

remote func mark_player_as_spawned(id):
	print ("Mark " + str(id) + " as spawned")
	for p in players.get_children():
		if p.get_name() == id:
			p.ready = true

func _process(delta):
	if (randi()%1000 + 1 == 5):
		var id = randi()%1000000000 + 1
		if id in mobs.get_children():
			return
		var who = "mob"
		var m = mob.new()
		m.set_name(str(id))
		mobs.add_child(m)
		rpc("spawn", who, id)
		
func _physics_process(delta):
	for m in mobs.get_children():
		m.move()
	for proj in projectiles.get_children():
		proj.move()
	for it in items.get_children():
		it.move()

var player_pos = Dictionary()
remote func player_position(id, pos):
	player_pos[id] = pos
	
func player_disconnect(id):
	#TODO: Fix some async error stuff
	#player_pos.erase(id)
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

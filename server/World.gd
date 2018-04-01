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


var entities = null
var players = null
var mobs = null
var items = null

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
	
	add_child(n)
	
	entities = get_node("/root/World/entities")
	players = get_node("/root/World/entities/players")
	mobs = get_node("/root/World/entities/mobs")
	items = get_node("/root/World/entities/items")

	get_node("/root/global_player").connect("player_disconnect", self, "player_disconnect")
	
	for p in global_player.player_info:
		var new_player = class_mage.new()
		new_player.set_name(str(p))
		#new_player.set_network_master(p)
		new_player.username = global_player.player_info[p]["username"]
		new_player.classtype = global_player.player_info[p]["classtype"]
		players.add_child(new_player)
		print("Spawned player")

remote func feed_me_player_info(id):
	print ("Feeding player data to " + str(id))
	for p in players.get_children():
		rpc_id(id,"spawn", "player", p.get_name())

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
		m.set_collision_layer(1)
		mobs.add_child(m)
		rpc("spawn", who, id)
		
func _physics_process(delta):
	for m in mobs.get_children():
		m.move()
		
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

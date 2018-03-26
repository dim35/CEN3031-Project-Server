extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var global_player = get_node("/root/global_player")
onready var entity = load("res://server/entity/entity.gd")
onready var mob = load("res://server/entity/Mob.gd")
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
	#var entity = load("res://server/entity/entity.gd").new()
	#entity.set_name("entity")
	#get_node("/root/World/entities").add_child(entity)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if (randi()%100 + 1 == 5):
		var id = randi()%1000000000 + 1
		if id in get_node("/root/World").get_children():
			return
		var who = "mob"
		var m = mob.new()
		m.set_name(str(id))
		mobs.add_child(m)
		rpc("spawn", who, id)
		
func _physics_process(delta):
	for m in mobs.get_children():
		m.move()
		
var player_pos = Dictionary()
remote func player_position(id, pos):
	player_pos[id] = pos
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

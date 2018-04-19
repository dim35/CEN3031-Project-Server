extends Node

onready var mob = load("res://server/entity/Mob.gd")
var mobs = null
var players = null

func _ready():
	pass

func _process(delta):
	for p in players.get_children():
		for spawn in p.cloest_mob_spawnpoints:
			if (randi()%1000 + 1 == 5):
				var id = randi()%1000000000 + 1
				if id in mobs.get_children():
					return
				var who = "mob"
				var m = mob.new()
				m.set_name(str(id))
				m.position = spawn.position
				mobs.add_child(m)
				get_tree().get_root().get_node("World").spawn_mob(who, id)
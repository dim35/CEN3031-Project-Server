extends Node

onready var mob = load("res://server/entity/Mob.gd")
var mobs = null

func _ready():
	pass


func _process(delta):
	if (randi()%500 + 1 == 5):
		var id = randi()%1000000000 + 1
		if id in mobs.get_children():
			return
		var who = "mob"
		var m = mob.new()
		m.set_name(str(id))
		mobs.add_child(m)
		get_tree().get_root().get_node("World").spawn_mob(who, id)


func _physics_process(delta):
	for m in mobs.get_children():
		m.move()

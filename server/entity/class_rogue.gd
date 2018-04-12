extends "res://server/entity/Player.gd"

onready var world = get_node("/root/World")

func _ready():
	classtype = "rogue"
	set_max_attributes(150, 100, 200, 10, 150, 1)
	
func attack():
	pass
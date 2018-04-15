extends "res://server/entity/Player.gd"

#onready var world = get_node("/root/World")
#onready var entities = get_node("/root/World/entities/mobs")


func _ready():
	classtype = "rogue"
	
	
func attack():
	for m in enemies_in_range:
		m.take_damage(damage)
		m.position.x += -(2*int(last_direction)-1) * 15
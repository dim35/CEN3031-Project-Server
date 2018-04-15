extends "res://server/entity/Player.gd"

onready var world = get_node("/root/World")
onready var entities = get_node("/root/World/entities/mobs")


func _ready():
	classtype = "rogue"
	set_max_attributes(150, 100, 200, 100, 150, 10)
	
	
func find_mob_in_attack_range():
	var minx = 50
	var near = []
	for m in entities.get_children():
		var x = position.distance_to(m.position)
		var A = position.x
		var B = position.x + -(2*int(last_direction)-1)*50
		var C = m.position.x
		if (x < minx and (abs(A-C) + abs(B-C) == abs(A-B))):
			near.append(m)
	return near
	
	
func attack():
	var mobs = find_mob_in_attack_range()
	if(mobs.size() != 0):
		for m in mobs:
			m.take_damage(damage)
			m.position.x += -(2*int(last_direction)-1) * 15
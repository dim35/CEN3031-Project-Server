extends "res://server/entity/Player.gd"

onready var entities = get_node("/root/World/entities/mobs")

func _ready():
	classtype = "knight"
	
func find_mob_in_attack_range():
	var minx = 50
	var near = null
	for m in entities.get_children():
		var x = position.distance_to(m.position)
		var A = position.x
		var B = position.x + -(2*int(last_direction)-1)*50
		var C = m.position.x
		if (x < minx and (abs(A-C) + abs(B-C) == abs(A-B))):
			minx = x
			near = m
	return near
func attack():
	var mob = find_mob_in_attack_range()
	if(mob != null):
		mob.take_damage(damage)
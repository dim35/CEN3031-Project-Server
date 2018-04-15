extends "res://server/entity/Player.gd"

const Cooldown = preload('res://server/Cooldown.gd')
onready var entities = get_node("/root/World/entities/mobs")

func _ready():
	classtype = "knight"
	set_max_attributes(200, 80, 150, 300, 150, 15)
	
func _process(delta):
	attack_cooldown.tick(delta)
onready var attack_cooldown = Cooldown.new(0.5)
	
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
	if(attack_cooldown.is_ready() and mobs.size() != 0):
		for m in mobs:
			m.take_damage(damage)
			m.position.x += -(2*int(last_direction)-1) * 30
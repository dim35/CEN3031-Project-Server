extends "res://server/entity/Player.gd"

#onready var world = get_node("/root/World")
#onready var entities = get_node("/root/World/entities/mobs")
const Cooldown = preload('res://server/Cooldown.gd')

func _ready():
	classtype = "rogue"
	

func _process(delta):
	attack_cooldown.tick(delta)
	
onready var attack_cooldown = Cooldown.new(0.01)

func attack():
	if(attack_cooldown.is_ready()):
		rpc("playStabs")
		for m in enemies_in_range:
			m.take_damage(damage)
			m.position.x += -(2*int(last_direction)-1) * 15
extends "res://server/entity/Player.gd"

const Cooldown = preload('res://server/Cooldown.gd')
#onready var entities = get_node("/root/World/entities/mobs")

func _ready():
	classtype = "knight"

	
func _process(delta):
	attack_cooldown.tick(delta)
onready var attack_cooldown = Cooldown.new(0.5)
	

func attack():
	if(attack_cooldown.is_ready()):
		for m in enemies_in_range:
			m.take_damage(damage)
			m.position.x += -(2*int(last_direction)-1) * 30
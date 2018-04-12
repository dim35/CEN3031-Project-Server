extends "res://server/entity/Player.gd"

onready var world = get_node("/root/World")
onready var projectiles = get_node("/root/World/entities/projectiles")
const Cooldown = preload('res://server/Cooldown.gd')

onready var shoot_cooldown = Cooldown.new(1.5)

func _ready():
	classtype = "mage"
func _process(delta):
	shoot_cooldown.tick(delta)
	
func attack():
	if (shoot_cooldown.is_ready()):
	# last_direction is boolean, so convert to -1 or 1
		world.spawn_fireball(position, -2*int(last_direction) + 1, get_path())
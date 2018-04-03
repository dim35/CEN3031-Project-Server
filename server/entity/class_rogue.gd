extends "res://server/entity/Player.gd"

onready var world = get_node("/root/World")


func _ready():
	classtype = "rogue"
	health = MAX_HEALTH
	stamina = MAX_STAMINA
	speed = MAX_SPEED
	defense = MAX_DEFENSE
	mana = MAX_MANA
	damage = MAX_DAMAGE
	
func attack():
	pass
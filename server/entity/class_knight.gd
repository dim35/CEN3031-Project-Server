extends "res://server/entity/Player.gd"

func _ready():
	classtype = "knight"
	health = MAX_HEALTH
	stamina = MAX_STAMINA
	speed = MAX_SPEED
	defense = MAX_DEFENSE
	mana = MAX_MANA
	damage = MAX_DAMAGE/3
	
func attack():
	pass
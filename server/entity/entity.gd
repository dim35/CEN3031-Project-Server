extends KinematicBody2D

var who = "none"

var GRAVITY = 12

var velocity = Vector2()

var state = "idle"

var MAX_HEALTH
var MAX_MANA
var MAX_STAMINA
var MAX_DEFENSE
var MAX_SPEED
var MAX_DAMAGE

var health
var mana
var stamina
var defense
var speed
var damage

func apply_gravity():
	velocity.y += GRAVITY

func _ready():
	var hitbox = CollisionShape2D.new()
	hitbox.set_name("hitbox")
	add_child(hitbox)

# Initializes the entity's max and current class attributes
func set_max_attributes(hp, mp, sta, def, agil, dmg):
	MAX_HEALTH = hp
	MAX_MANA = mp
	MAX_STAMINA = sta
	MAX_DEFENSE = def
	MAX_SPEED = agil
	MAX_DAMAGE = dmg
	health = MAX_HEALTH
	mana = MAX_MANA
	stamina = MAX_STAMINA
	defense = MAX_DEFENSE
	speed = MAX_SPEED
	damage = MAX_DAMAGE

func check_position():
	if position.y > 650:
		position = get_tree().get_root().get_node("World/Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
		#position = Vector2(0,0)
		velocity.y = 0
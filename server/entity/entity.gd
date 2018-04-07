extends KinematicBody2D

var who = "none"

var GRAVITY = 12

var velocity = Vector2()

var state = "idle"

var MAX_HEALTH = 100
var MAX_MANA = 100
var MAX_STAMINA = 100
var MAX_DEFENSE = 100
var MAX_SPEED = 100
var MAX_DAMAGE = 25

var health = 0
var mana = 0
var stamina = 0
var defense = 0
var speed = 0
var damage = 0

func apply_gravity():
	velocity.y += GRAVITY

func _ready():
	var hitbox = CollisionShape2D.new()
	hitbox.set_name("hitbox")
	add_child(hitbox)
	pass
	
	
func check_position():
	if position.y > 650:
		position = get_tree().get_root().get_node("World/Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
		#position = Vector2(0,0)
		velocity.y = 0
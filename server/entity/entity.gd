extends KinematicBody2D

var who = "none"

var GRAVITY = 12

var velocity = Vector2()
var health

var state = "idle"

func apply_gravity():
	velocity.y += GRAVITY

func _ready():
	pass
	
	
func check_position():
	if position.y > 650:
		position = Vector2(0,0)
		velocity.y = 0
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
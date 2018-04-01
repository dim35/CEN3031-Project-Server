extends "res://server/entity/entity.gd"

var direction = 1 # -1 or 1

var speed = 5


func _ready():
	who = "projectile"
	var hitbox = CollisionShape2D.new()
	add_child(hitbox)

func move():
	move_and_collide(Vector2(direction*speed, 0))
	rpc("remote_move", position, direction)
extends "res://server/entity/entity.gd"

var id = 0

func _ready():
	who = "item"
	var hitbox = CollisionShape2D.new()
	hitbox.set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	add_child(hitbox)
	
func move():
	#if !is_on_floor():
	#	velocity.y += 12
	#	move_and_slide(velocity) # small optimization to leave move here
	rpc("remote_move", position)
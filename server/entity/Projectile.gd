extends "res://server/entity/entity.gd"

var direction = 1 # -1 or 1

var big_boi_player

var timer = 3 # last for 3 seconds

func _ready():
	speed = 5
	who = "projectile"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	set_collision_layer_bit(Base.PROJECTILE_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	#set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	#set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles

func _process(delta):
	timer = timer - delta

func _physics_process(delta):
	move()	

func move():
	if (timer < 0):
		rpc("delete_me")
		queue_free()
	var collision = move_and_collide(Vector2(direction*speed, 0))
	if collision != null:
		if collision.collider.is_class("TileMap"):
			direction = -1*direction
		else:
			match collision.collider.who:
				"mob":
					collision.collider.take_damage(big_boi_player.damage)
					rpc("delete_me")
					queue_free()
	rpc("remote_move", position, direction)
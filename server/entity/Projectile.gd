extends "res://server/entity/entity.gd"

var direction = 1 # -1 or 1

var speed = 5


func _ready():
	who = "projectile"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	set_collision_layer_bit(Base.PROJECTILE_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	#set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	#set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles

func move():
	move_and_collide(Vector2(direction*speed, 0))
	rpc("remote_move", position, direction)
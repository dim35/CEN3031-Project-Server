extends "res://server/entity/entity.gd"

var id = 0

func _ready():
	who = "item"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/mob_hitbox.tres"))
	set_collision_layer_bit(Base.ITEM_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	#set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	#set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles
	
func move():
	#if !is_on_floor():
	#	velocity.y += 12
	#	move_and_slide(velocity) # small optimization to leave move here
	rpc("remote_move", position)
	
func picked_up(id):
	rpc_id(int(id), "picked_up")
	rpc("delete_me")
	queue_free()
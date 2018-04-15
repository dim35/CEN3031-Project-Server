extends "res://server/entity/entity.gd"

var id

onready var world = get_tree().get_root().get_node("World")

func _ready():
	#id=0 health potion
	#id=1 stamina potion
	id = randi()%2
	
	who = "item"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/mob_hitbox.tres"))
	set_collision_layer_bit(Base.ITEM_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	#set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	#set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles
	
func move():
	if !is_on_floor():
		velocity.y += 12
		move_and_slide(velocity) # small optimization to leave move here
	rpc("remote_move", position)
	
func picked_up(i):
	i.inventory[id] += 1
	world.update_inventory_to_client(i)
	rpc_id(int(i.get_name()), "picked_up")
	rpc("delete_me")
	queue_free()
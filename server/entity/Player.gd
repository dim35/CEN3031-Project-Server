extends "res://server/entity/entity.gd"

var username
var classtype
var ready

func _ready():
	who = "player"
	ready = false
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	position = Vector2(randi()%10, 0)
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	set_collision_mask_bit(Base.ITEM_COLLISION_LAYER, true) # players
	
var last_direction = 0
var is_attacking

remote func move(v, is_atk):
	velocity += v
	is_attacking = is_atk
	var new_anim = "idle"
	if (velocity.x != 0):
		last_direction = velocity.x < 0
	if (is_attacking):
		new_anim = "attacking"
		attack()
	elif velocity.x != 0 and test_move(transform, Vector2(0,1)):
		new_anim = "walking"
	elif !test_move(transform, Vector2(0,1)):
		new_anim = "falling"
	
	state = new_anim
	
remote func set_to_idle():
	state = "idle"

func _physics_process(delta):
	# gravity update is server side
	if !test_move(transform, Vector2(0,1)):
		apply_gravity()
	elif velocity.y > 0:
		velocity.y = 0
	check_position()
	move_and_slide(velocity)
	rpc("remote_move", position, velocity, state, last_direction)
	# set velocity of x to zero after each time we move
	
	velocity.x = 0
	
	if (get_slide_count() > 0):
		for i in range(get_slide_count()):
			var kc2D = get_slide_collision(i)
			if kc2D.collider.is_class("TileMap"):
				continue
			match kc2D.collider.who:
				"item":
					kc2D.collider.picked_up(get_name())
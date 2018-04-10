extends "res://server/entity/entity.gd"

var username
var classtype
var ready

var inventory = Dictionary()

var w = null

func _ready():
	w = get_tree().get_root().get_node("World")
	who = "player"
	ready = false
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	
	#Spawn at start if beginning of game or if one player present
	if (w.get_node("entities/players").get_child_count() == 1 || !w.get_node("Spawning/PlayerSpawner").respawn):
		position = w.get_node("Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
	
	#Respawn on teammates if available
	else:
		var index = randi()%w.get_node("entities/players").get_child_count()
		position = w.get_node("entities/players").get_child(index).get_global_position()
	
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	set_collision_mask_bit(Base.ITEM_COLLISION_LAYER, true) # players
	
var last_direction = 0
var is_attacking

remote func move(v, is_atk):
	if v.y < 0:
		if !(is_on_floor() or test_move(transform, Vector2(0,1))):
			v.y = 0
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


#overrides func in entity.gd
func check_position():
	if position.y > 650:
		if w.get_node("entities/players").get_child_count() == 1:
			position = w.get_node("Spawning/PlayerSpawnPoints").get_child(0).get_global_position()
		else:
			var index = randi()%w.get_node("entities/players").get_child_count()
			position = w.get_node("entities/players").get_child(index).get_global_position()
		velocity.y = 0
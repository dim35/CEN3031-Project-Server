extends "res://server/entity/entity.gd"

var username
var classtype
var ready

func _ready():
	who = "player"
	ready = false
	var hitbox = CollisionShape2D.new()
	hitbox.set_shape(load("res://server/entity/entity_resources/PlayerHitbox.tres"))
	add_child(hitbox)
	position = Vector2(randi()%10, 0)
	
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

	move_and_slide(velocity)
	rpc("remote_move", position, velocity, state, last_direction)
	# set velocity of x to zero after each time we move
	
	velocity.x = 0
	
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
	
remote func move(v):
	velocity += v
	

func _physics_process(delta):
	# gravity update is server side
	if !test_move(transform, Vector2(0,1)):
		apply_gravity()
	elif velocity.y > 0:
		velocity.y = 0
	print(velocity)
	move_and_slide(velocity)
	rpc("remote_move", position, velocity)
	# set velocity of x to zero after each time we move
	velocity.x = 0
	
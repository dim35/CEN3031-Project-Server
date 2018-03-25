extends Node

var SERVER_PORT = 5555
var MAX_PLAYERS = 5
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var players = []
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	print('Test')

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _init():
	pass


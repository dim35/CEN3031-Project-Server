extends Node

var SERVER_PORT = 5555
var MAX_PLAYERS = 5
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_info = {}
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print('Started server...')
	
func _player_disconnected(id):
	print(str(id) + "(" + player_info[id]["username"] + " " + player_info[id]["classtype"] + ") disconnected")
	player_info.erase(id)
	
remote func register_player(id, info):
	# Store the info
	player_info[id] = info
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
		print (str(id) + "(" + info["username"] + " " + info["classtype"] + ") connected")
		# Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _init():
	pass

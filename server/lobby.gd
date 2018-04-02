extends Node

var SERVER_PORT = 5555
var MAX_PLAYERS = 5
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal player_disconnect(id)

var in_play = false

var player_info = {}
var players_done = []
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
	if (id in players_done):
		players_done.erase(id)
	emit_signal("player_disconnect", id)
	if player_info.size() == 0 and players_done.size() == 0 and in_play:
		get_node("/root/World").queue_free()
		in_play = false
		print("Returning to lobby...")
		
	
remote func register_player(id, info):
	# Alert everyone of new player
	for peer_id in player_info:
		rpc_id(peer_id, "register_player", id, info)
		
	player_info[id] = info

	print (str(id) + "(" + info["username"] + " " + info["classtype"] + ") connected")
	# Send the info of existing players
	for peer_id in player_info:
		rpc_id(id, "register_player", peer_id, player_info[peer_id])


remote func done_preconfiguring(who):
	assert(who in player_info)
	print (str(who) + " ready")
	players_done.append(who)
	if (players_done.size() == player_info.size()):
		print ("All players ready! Begin")
		rpc("post_configure_game")
		post_configure_game()

remote func post_configure_game():
	var world = preload("res://server/World.tscn").instance()
	world.set_name("World")
	get_node("/root/").add_child(world)
	in_play = true
	pass

remote func change_class(id, c):
	player_info[id]["classtype"] = c
	print (str(id) + "(" + player_info[id]["username"] + " changed class to " + player_info[id]["classtype"] + ")")	

func _init():
	pass


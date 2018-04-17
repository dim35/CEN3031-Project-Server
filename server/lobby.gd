extends Node

var SERVER_PORT = 5555
var MAX_PLAYERS = 5

var http = HTTPClient.new()
var HTTP_PORT = 443

signal player_disconnect(id)

var in_play = false

var player_info = {}
var player_tokens = {}
var players_done = []

var current_level = 0
const final_level = 3
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	#set_data("daniel", "Knight", {0:5, 1:2}, 95, 70, 50, 500, 0)
	print('Started server...')
	
func _player_disconnected(id):
	if not (id in player_info.keys()):
		return
	print(str(id) + "(" + player_info[id]["username"] + " " + player_info[id]["classtype"] + ") disconnected")
	player_info.erase(id)
	if (id in players_done):
		players_done.erase(id)
	emit_signal("player_disconnect", id)
	if player_info.size() == 0 and players_done.size() == 0 and in_play:
		get_node("/root/World").queue_free()
		in_play = false
		current_level = 0
		print("Returning to lobby...")
		
	
remote func register_player(id, info, session_token):
	for peer_id in player_info.keys():
			if player_info[peer_id]["username"] == info["username"] and player_tokens[peer_id] != session_token:
				rpc_id(id, "existing_session")
				print("Existing token for " + info["username"])
				return
	if in_play:
		rpc_id(id, "game_in_play")
		return
	# Alert everyone of new player
	for peer_id in player_info:
		rpc_id(peer_id, "register_player", id, info)
	
	player_info[id] = info
	player_tokens[id] = session_token

	print (str(id) + "(" + info["username"] + " " + info["classtype"] + ") connected")
	
	# inform connected player about itself first
	rpc_id(id, "register_player", id, info)
	# Send the info of existing players
	for peer_id in player_info:
		if peer_id != id:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])


remote func done_preconfiguring(who):
	assert(who in player_info)
	print (str(who) + " ready")
	players_done.append(who)
	for p in player_info.keys():
		if p == who:
			continue
		rpc_id(p, "who_is_ready", players_done)
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
	player_info[id]["info"] = get_data(player_info[id]["username"], player_info[id]["classtype"])
	print (str(id) + "(" + player_info[id]["username"] + " changed class to " + player_info[id]["classtype"] + ")")	

func finished_loading():
	rpc("finished_loading")

func load_next_map():
	current_level += 1
	if (current_level == final_level):
		rpc("we_done_bois")
		return
	var next_world = "World"
	if (current_level == 0): # shouldn't happen, but whatevs
		next_world = next_world
	else:
		next_world = next_world+str(current_level)
	rpc("load_next_map", next_world)

	get_node("/root/World").set_name("OldWorldFreeing")
	get_node("/root/OldWorldFreeing").queue_free()

	var world = load("res://server/"+next_world+".tscn").instance()
	world.set_name("World")
	get_node("/root/").add_child(world)
	in_play = true

func get_data(username, classtype):
	# connect to ip address
	http.connect_to_host("54.175.123.188", HTTP_PORT, true, false)
	
	# wait until connected
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting........")
		OS.delay_msec(500)
	
	# if failed return
	if (http.get_status() != HTTPClient.STATUS_CONNECTED):
		print("Server could not connect")
		assert(true)
	var query = http.query_string_from_dict({"username": username, "class": classtype})
	var headers = [
		"Content-Type: application/x-www-form-urlencoded",
		"Content-Length: " + str(query.length())
	]
	http.request(HTTPClient.METHOD_POST, "/api/getdata", headers, query)
	
	# wait until finished requesting
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		print ("Requesting...........")
		OS.delay_msec(300)
		
	# if failed return
	if(http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED):
		http.close()
		return null
		
	# verify error
	var code = http.get_response_code()

	if code == 200 or code == 201:
		var chunk = http.read_response_body_chunk().get_string_from_ascii()
	
		var dict = parse_json(chunk)
		http.close()
		return [code, dict]
	http.close()
	return null
	
func set_data(params):
	# connect to ip address
	http.connect_to_host("54.175.123.188", HTTP_PORT, true, false)
	
	# wait until connected
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(500)
	
	# if failed return
	if (http.get_status() != HTTPClient.STATUS_CONNECTED):
		print("Server could not connect")
		http.close()		
		assert(true)
	var query = http.query_string_from_dict({"username": params["username"], "class": params["classtype"], "items":params["items"],
											"health":params["health"], "stamina":params["stamina"], "mana":params["mana"],
											"posx": params["posx"], "posy":params["posy"]})
	var headers = [
		"Content-Type: application/x-www-form-urlencoded",
		"Content-Length: " + str(query.length())
	]
	http.request(HTTPClient.METHOD_POST, "/api/setdata", headers, query)
	
	# wait until finished requesting
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(300)
		
	# if failed return
	if(http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED):
		print("Didn't get request")
		http.close()
		return null
		
	var chunk = http.read_response_body_chunk().get_string_from_ascii()
	
	var dict = parse_json(chunk)
	print(dict)
	http.close()
	return true
extends Node

onready var global_player = get_node("/root/global_player")
onready var player = preload("res://server/entity/Player.gd")
onready var class_knight = preload("res://server/entity/class_knight.gd")
onready var class_mage = preload("res://server/entity/class_mage.gd")
onready var class_rogue = preload("res://server/entity/class_rogue.gd")

var player_pos = Dictionary()
var players = null

var respawn = false

func _ready():
	get_node("/root/global_player").connect("player_disconnect", self, "player_disconnect")
	pass
	
func arr_to_dict(arr):
	var dict = Dictionary()
	for i in range(5): # oh boy
		dict[i] = 0
	for i in range(arr.size()):
		dict[i] = int(arr[i])
	return dict
		#dic[x] = int(dic[x])

func spawn_initial(params):
	for p in global_player.player_info:
		var ctype = global_player.player_info[p]["classtype"]
		var new_player = null
		if ctype == "Knight":
			new_player = class_knight.new()
			new_player.set_max_attributes(200, 80, 150, 300, 150, 15)
		elif ctype == "Mage":
			new_player = class_mage.new()
			new_player.set_max_attributes(80, 200, 100, 80, 100, 50)
		elif ctype == "Rogue":
			new_player = class_rogue.new()
			new_player.set_max_attributes(150, 100, 200, 100, 150, 10)
		new_player.set_name(str(p))
		new_player.classtype = ctype
		#new_player.set_network_master(p)
		new_player.username = global_player.player_info[p]["username"]
		new_player.classtype = global_player.player_info[p]["classtype"]
		var info = global_player.get_data(new_player.username, new_player.classtype)
		print (info)
		if info[0] == 200:
			new_player.health = info[1]["health"]
			new_player.stamina = info[1]["stamina"]
			new_player.mana = info[1]["mana"]
			new_player.position.x = info[1]["posx"]
			new_player.position.y = info[1]["posy"]
			new_player.old_pos = true
		info[1]["items"] = arr_to_dict(parse_json(info[1]["items"]))
		global_player.player_info[p]["data"] = info[1]
		new_player.inventory = info[1]["items"]
		
		players.add_child(new_player)
		respawn = true
	global_player.finished_loading()
	
	return true


func player_disconnect(id):
	players.get_node(str(id)).free()

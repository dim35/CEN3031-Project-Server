extends Node

onready var global_player = get_node("/root/global_player")
onready var player = load("res://server/entity/Player.gd")
onready var class_knight = load("res://server/entity/class_knight.gd")
onready var class_mage = load("res://server/entity/class_mage.gd")
onready var class_rogue = load("res://server/entity/class_rogue.gd")

var player_pos = Dictionary()
var players = null

var respawn = false

func _ready():
	pass


func spawn_initial():
	get_node("/root/global_player").connect("player_disconnect", self, "player_disconnect")
	
	for p in global_player.player_info:
		var ctype = global_player.player_info[p]["classtype"]
		var new_player = null
		if ctype == "Knight":
			new_player = class_knight.new()
		elif ctype == "Mage":
			new_player = class_mage.new()
		elif ctype == "Rogue":
			new_player = class_rogue.new()
		new_player.set_name(str(p))
		new_player.classtype = ctype
		#new_player.set_network_master(p)
		new_player.username = global_player.player_info[p]["username"]
		new_player.classtype = global_player.player_info[p]["classtype"]
		players.add_child(new_player)
		respawn = true
		
		print("Spawned player")


func player_disconnect(id):
	players.get_node(str(id)).free()

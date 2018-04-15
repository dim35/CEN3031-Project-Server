extends Node

onready var item = load("res://server/entity/Item.gd")
var items = null

func _ready():
	pass

func spawn_item(pos):
	var unique_id = randi()%10000000000 + 1 # <== Better hope we don't generate two of the same id	
	var new_item = item.new()
	new_item.set_name(str(unique_id))
	new_item.position = pos
	new_item.id = randi()%2
	
	print("Newly created item with id = ", new_item.id)
	
	get_tree().get_root().get_node("World").item_drop(unique_id, new_item.id)
	items.add_child(new_item)


func _physics_process(delta):
	if items.get_child_count() > 0:
		for it in items.get_children():
			it.move()

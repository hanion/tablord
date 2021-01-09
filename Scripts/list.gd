extends Node

var players := {}

func _clear_list():
	players.clear()
	print("list cleard")

func _add_player_to_list(var id:int,var _Name:="UNKNOWN"):
	if players.has(id):
		print("list already has this id",id)
	else:
		players[id] = _Name
		print(_Name," (",id,") "," added to list")
		

func _remove_player_from_list(var id:int):
	if players.has(id):
		var er = players.erase(id)
		print(id," removed from list, ",er)
	else:
		print("player ",id," does not exist")

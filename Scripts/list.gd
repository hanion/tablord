extends Node

var players := [[],[]]
#         action : 0=disconnect  1=connect
signal player_list_changed(action,_id)

func _clear_list():
	players[0].clear()
	players[1].clear()
	print("list cleard")

func _add_player_to_list(var id:int,var _Name:="UNKNOWN"):
	if players[0].has(id):
		print("list already has this id",id)
	else:
		players[0].append(id)
		players[1].append(_Name)
		print(_Name," (",id,") "," added to list")
		
		emit_signal("player_list_changed",1,id)

func _remove_player_from_list(var id:int):
	if players[0].has(id):
		var _name = players[1][players[0].find(id)]
		players[0].erase(id)
		players[1].erase(_name)
		print(id," removed from list")
		emit_signal("player_list_changed",0,id)
	else:
		print("player ",id," does not exist")

extends Spatial

func _ready():
	List.connect("player_list_changed",self,"_plist_changed")
	for p in List.players[0]:
		_add_plo(p)

#TODO make a puppet system 
# : if player is not me then spawn puppet
# puppet is : game obj but without controller script or camera 
func _add_plo(var id):
	var plo = preload("res://Scenes/ployero.tscn").instance()
	plo.set_name(str(id))
	plo.set_network_master(id)
	plo.translation = Vector3(2,2,1)
	add_child(plo)


func _plist_changed(action,id):
	if id == get_tree().get_network_unique_id():
		return false
	
	if action == 1:
		_add_plo(id)
	else:
		#TODO delete player object
		pass

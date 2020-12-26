extends Spatial

func _ready():
	rpc_config("_my_pos",MultiplayerAPI.RPC_MODE_REMOTE)
	var _asdasdasd = List.connect("player_list_changed",self,"_plist_changed")
	for p in List.players[0]:
		_add_plo(p)

#TODO make a puppet system 
# : if player is not me then spawn puppet
# puppet is : game obj but without controller script or camera 
func _add_plo(var id):
	if id == get_tree().get_network_unique_id():
		return
	
	var plo = preload("res://Scenes/puppet.tscn").instance()
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


func my_pos(var id: int,var pos: Vector3,var orr: Vector3):
	rpc_unreliable_id(0,"_my_pos",id,pos,orr)

remote func _my_pos(id,pos,orr):
	var old_pos = get_node(str(id)+"/Elevation/Camera").global_transform.origin
	old_pos = lerp(old_pos,pos,0.5)
	get_node(str(id)+"/Elevation/Camera").global_transform.origin = old_pos
#	get_node(str(id)+"/Elevation/Camera").global_transform.origin = pos
	get_node(str(id)+"/origin").global_transform.origin = orr










#func _on_Dragable_drag_move(node, cast):
#	$dice.set_translation(cast['position']+Vector3())

extends Spatial

var currently_moving := []
#TODO rewrite all of the code

#######################
# OVERRIDE FUNCTIONS 
#######################
func _ready():
	if not get_tree().has_network_peer():
		set_physics_process(false)
	rpc_config("_my_pos",MultiplayerAPI.RPC_MODE_REMOTE)
	var _asdasdasd = List.connect("player_list_changed",self,"_plist_changed")
	
	for p in List.players[0]:
		_add_plo(p)
	


func _physics_process(_delta):
	if currently_moving.size()>0:
		for obj in currently_moving:
			if obj.sleeping:
				currently_moving.erase(obj)
				continue
			obj_pos(obj.name,obj.translation)


#######################
# FUNCTIONS 
#######################
func _register_moving_obj(var obj):
	if not currently_moving.has(obj):
		currently_moving.append(obj)
#		obj.sleeping = false
	



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




func my_pos(var pos: Vector3,var orr: Vector3):
	rpc_unreliable_id(0,"_my_pos",pos,orr)
remote func _my_pos(pos,orr):
	var id = get_tree().get_rpc_sender_id()
	var old_pos = get_node(str(id)+"/Elevation/Camera").global_transform.origin
	old_pos = lerp(old_pos,pos,0.5)
	get_node(str(id)+"/Elevation/Camera").global_transform.origin = old_pos
#	get_node(str(id)+"/Elevation/Camera").global_transform.origin = pos
	get_node(str(id)+"/origin").global_transform.origin = orr


func obj_pos(var obj_name,var pos:Vector3)->void:
	rpc_unreliable_id(0,"_obj_pos",obj_name,pos)
remote func _obj_pos(obj_name,pos):
	get_node(obj_name).translation = pos

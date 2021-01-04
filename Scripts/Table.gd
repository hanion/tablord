extends Spatial

var currently_moving := []
var last_world_state = 0
#TODO rewrite all of the code

#######################
# OVERRIDE FUNCTIONS 
#######################
func _ready():
	if not get_tree().has_network_peer():
		set_physics_process(false)
	rpc_config("_my_pos",MultiplayerAPI.RPC_MODE_REMOTE)
	
	for p in List.players[0]:
		_add_plo(p)

#######################
# FUNCTIONS 
#######################
func _add_plo(var id):
	if id == get_tree().get_network_unique_id():
		return
	
	var plo = preload("res://Scenes/puppet.tscn").instance()
	plo.set_name(str(id))
	plo.set_network_master(id)
#	plo.translation = Vector3(2,2,1)
	get_node("OtherPlayers").add_child(plo)


# received world state from host
func process_received_world_state(world_state):
	# Buffer
	# Interpolate
	# Extrapolate
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(get_tree().get_network_unique_id())
		for player in world_state.keys():
			if get_node("OtherPlayers").has_node(str(player)):
				move_player(
					player,world_state[player]["P"])
			else:
				#MAYBE spawn player
				printerr("Player doesn't exist in scene")


func move_player(player,_P):
	var _puppet = get_node("OtherPlayers/"+str(player))
	_puppet.rotation_degrees.y = _P.x
	_puppet.get_node("Elevation").rotation_degrees.x = _P.y
	_puppet.get_node("Elevation/Camera").translation.z = _P.z
	





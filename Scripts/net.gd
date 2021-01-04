extends Node
#######################
# CONFIG
#######################
func _ready():
	rpc_config("receive_cam_state",MultiplayerAPI.RPC_MODE_MASTERSYNC)
	rpc_config("receive_world_state",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
#######################
# CONNECTIONS
#######################
func host_server(var port := 4014, var max_peer := 8):
	var _net = NetworkedMultiplayerENet.new()
	_net.create_server(port, max_peer)
	get_tree().set_network_peer(_net)
func join_server(var ip := "127.0.0.1",var port := 4014):
	var _net = NetworkedMultiplayerENet.new()
	_net.create_client(ip, port)
	get_tree().set_network_peer(_net)

#######################
# INTERFACE
#######################
func send_cam_state(var cam_state):
	rpc_unreliable_id(1,"receive_cam_state",cam_state)






#######################
# CLIENT
#######################
# called every time when some peer connects to us
## from Main peer_connected
# the peer who connected to us gives info to us
remote func new_peer_connected(var Name,var _color := 1,var _shape := 1):
	var id = get_tree().get_rpc_sender_id()
	List._add_player_to_list(id,Name)
	print("got the info, name is ",Name," and id is ",id)
	
	# spawn puppet node of the player connected 
	get_node("/root/Table")._add_plo(id)

remote func receive_world_state(world_state):
	get_node("/root/Table").process_received_world_state(world_state)



#######################
# HOST
#######################
var cam_state_collection := {}


remote func receive_cam_state(var cam_state):
	var player_id = get_tree().get_rpc_sender_id()
	if cam_state_collection.has(player_id):
		if cam_state_collection[player_id]["T"] < cam_state["T"]:
			cam_state_collection[player_id] = cam_state
	else:
		cam_state_collection[player_id] = cam_state


func send_world_state(world_state):
	rpc_unreliable("receive_world_state",world_state)













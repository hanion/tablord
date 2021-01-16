extends Node
var Table
#######################
# CONFIG
#######################
func _ready():
	rpc_config("receive_state",MultiplayerAPI.RPC_MODE_MASTERSYNC)
	rpc_config("h_create_deck",MultiplayerAPI.RPC_MODE_MASTERSYNC)
	rpc_config("h_add_to_deck",MultiplayerAPI.RPC_MODE_MASTERSYNC)
	
	rpc_config("receive_world_state",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("c_create_deck",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("c_add_to_deck",MultiplayerAPI.RPC_MODE_REMOTESYNC)
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
var _frames := 0
onready var update_frame_time = $state_processor.update_frame_time
func send_state(state):
	if List.players.size() == 0: return # if im testing the game
	if List.players.size() == 1: return # if player is alone
	_frames += 1
	if _frames%update_frame_time == 0:
		rpc_unreliable_id(1,"receive_state",state)
		_frames = 0
	

func create_deck(holding,base):
	print("netcreate")
	rpc_id(1,"h_create_deck",holding,base)
func add_to_deck(holding,deck):
	print("netadd")
	rpc_id(1,"h_add_to_deck",holding,deck)

#######################
# CLIENT
#######################
# called every time when some peer connects to us
## from Main peer_connected
# the peer who connected to us gives info to us
remote func new_peer_connected(var Name,var _color := 1,var _shape := 1):
	Table = get_node("/root/Table")
	#TODO add colors
	var id = get_tree().get_rpc_sender_id()
	List._add_player_to_list(id,Name)
	print(Name,":",id,",",_color,",",_shape)
	
	# spawn puppet node of the player connected 
	Table._add_plo(id)

remote func receive_world_state(world_state):
	if world_state.empty():
		print("WTF ITS EMPTY RECEİVERERERER")
	Table.process_received_world_state(world_state)

remote func c_create_deck(holding,base):
	Table = get_node("/root/Table")#FOR TESTİNG
	Table.create_deck(holding,base)
remote func c_add_to_deck(holding,deck):
	Table = get_node("/root/Table")#FOR TESTİNG
	Table.add_to_deck(holding,deck)
#######################
# HOST
#######################
var world_state_collection := {}


remote func receive_state(state):
	if state.has(0):
		if world_state_collection.has(0):
			if world_state_collection[0]["T"] < state[0]["T"]:
				world_state_collection[0] = state[0]
		else:
			world_state_collection[0] = state[0]
		return
	
	
	var player_id = get_tree().get_rpc_sender_id()
	if world_state_collection.has(player_id):
		if world_state_collection[player_id]["T"] < state["T"]:
			world_state_collection[player_id] = state
	else:
		world_state_collection[player_id] = state
	


func send_world_state(world_state):
	if world_state.empty():
		print("WTF ITS EMPTYSEND WORLD STATETA")
	rpc_unreliable("receive_world_state",world_state)


remote func h_create_deck(holding,base):
	# Validate
	print("h_create")
	rpc("c_create_deck",holding,base)

remote func h_add_to_deck(holding,deck):
	# Validate
	rpc("c_add_to_deck",holding,deck)








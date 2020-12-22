extends Control

var ip = "127.0.0.1"
var port = 6969
var Name = ""



func _ready():
	rpc_config("id_give_my_info",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	var _c=get_tree().connect("network_peer_connected", self,"_player_connected")
	var _d=get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	var _sd=get_tree().connect("server_disconnected", self,"_server_disconnected")
	var _s=get_tree().connect("connected_to_server", self, "_connected_to_server")
	$online_margin/host/VBox/ip.text = str(IP.get_local_addresses()).split(",",false)[0].right(1)


##########################################
#                                        #
#               NETWORKING               #
#                                        #
##########################################

func _connected_to_server():
	print("connected to server")
	List._add_player_to_list(get_tree().get_network_unique_id(),Name)
	spawn_game()

func _player_connected(id):
#	List._add_player_to_list(id)
	rpc_id(id,"id_give_my_info",Name)
	print("player connected:",id)
#	_add_new_player_to_game(id)


func _player_disconnected(id):
	print("player disconnected:",id)
	List._remove_player_from_list(id)

func _server_disconnected():
	#TODO disconnect, return to main menu
#	get_tree().get_network_peer().close_connection(1)
	$online_margin/primer.visible = true
	$online_margin/host.visible = false
	$online_margin/join.visible = false
	print("server disconnected")


remote func id_give_my_info(var _Name):
	List._add_player_to_list(get_tree().get_rpc_sender_id(),_Name)
	print("got the info, name is ",_Name," and id is ",get_tree().get_rpc_sender_id())


func spawn_game():
	var game = preload("res://Scenes/Table.tscn").instance()
	get_parent().add_child(game)
	hide()

#func _add_new_player_to_game(var id):
#	if get_tree().get_root().has_node("Table"):
#		get_node("../Table")._add_plo(id)
#	else:
#		while not get_tree().get_root().has_node("Table"):
#			yield(get_tree().create_timer(1),"timeout")
#			if get_tree().get_root().has_node("Table"):
#				get_node("../Table")._add_plo(id)



###PRIMER

func _on_name_text_changed(new_text):
	if new_text.length() > 2:
		Name = new_text
		$online_margin/primer/HBox/host.disabled = false
		$online_margin/primer/HBox/join.disabled = false
	else:
		$online_margin/primer/HBox/host.disabled = true
		$online_margin/primer/HBox/join.disabled = true

func _on_join_pressed():
	$online_margin/primer.visible = false
	$online_margin/join.visible = true

func _on_host_pressed():
	$online_margin/primer.visible = false
	$online_margin/host.visible = true

###SECONDARY

func _on_ip_text_changed(new_text):
	ip = new_text

func _on_port_text_changed(new_text):
	port = int(new_text)


func _on_cancel_pressed():
	$online_margin/primer.visible = true
	$online_margin/host.visible = false
	$online_margin/join.visible = false




###JOIN
func _on_jjoin_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client(ip, port)
	get_tree().set_network_peer(net)

###HOST
func _on_hhost_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(port, 8)
	get_tree().set_network_peer(net)
	# add myself to my list
	List._add_player_to_list(get_tree().get_network_unique_id(),Name)
	spawn_game()





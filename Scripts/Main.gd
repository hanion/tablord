extends Control

export(int,2,30) var max_peer = 8


var ip = "127.0.0.1"
var port = 4014
var Name = ""



func _ready():
	get_node("online_margin/primer/name").grab_focus()
	net.rpc_config("new_peer_connected",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	var _c=get_tree().connect("network_peer_connected", self,"_player_connected")
	var _d=get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	var _sd=get_tree().connect("server_disconnected", self,"_server_disconnected")
	var _s=get_tree().connect("connected_to_server", self, "_connected_to_server")
	$online_margin/host/VBox/ip.text = (
			str(IP.get_local_addresses()).split(",",false)[0].right(1)
			+ "," +
			str(IP.get_local_addresses()).split(",",false)[1].right(1))

##########################################
#                                        #
#               NETWORKING               #
#                                        #
##########################################

# HOST
func _on_hhost_pressed():
	net.host_server()
	spawn_game()

# JOIN
func _on_jjoin_pressed():
	net.join_server()


func _connected_to_server():
	print("connected to server")
	spawn_game()

func _player_connected(id):
	net.rpc_id(id,"new_peer_connected",Name)
	print("player connected:",id)

func _player_disconnected(id):
	print("player disconnected:",id)
	List._remove_player_from_list(id)


func _server_disconnected():
	#TODO disconnect, return to main menu
	$online_margin/primer.visible = true
	$online_margin/host.visible = false
	$online_margin/join.visible = false
	print("server disconnected")


func spawn_game():
	# add myself to my list
	List._add_player_to_list(get_tree().get_network_unique_id(),Name)
	
	var game = preload("res://Scenes/Table.tscn").instance()
	get_parent().add_child(game)
	hide()


##########################################
#                                        #
#                   UI                   #
#                                        #
##########################################

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









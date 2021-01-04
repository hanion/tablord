extends Node

var world_state = {}

var _frames := 0
func _physics_process(_delta):
	if get_parent().cam_state_collection.empty(): return
	
#	if get_tree().has_network_peer():
	if true:
		# if we are not the host, delete processor
		if not get_tree().is_network_server():
			queue_free()
		
		_frames += 1
		if _frames%3 == 0:
			process_state()
			_frames = 0



func process_state():
	world_state = get_parent().cam_state_collection.duplicate(true)
	for player in world_state.keys():
		world_state[player].erase("T")
	world_state["T"] = OS.get_system_time_msecs()
	# Anti cheat
	# checks
	get_parent().send_world_state(world_state)

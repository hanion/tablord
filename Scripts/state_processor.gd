extends Node

var world_state = {}
var last_world_state = {}

var _frames := 0
func _physics_process(_delta):
	if get_parent().cam_state_collection.empty(): return
	if not get_tree().has_network_peer(): return
	
	if true:
		# if we are not the host, delete processor
		if not get_tree().is_network_server():
			queue_free()
		
		_frames += 1
		if _frames%2 == 0:
			process_state()
			_frames = 0



func process_state():
	world_state = get_parent().cam_state_collection.duplicate(true)
	# if there isnt any update then return
	if world_state.empty(): return
	
	if last_world_state.empty():
		last_world_state = world_state.duplicate(true)
	# if someone joined and size changed
	elif last_world_state.size()<world_state.size():
		# update everyones state once
		## for adding new player to the list and
		### for new player to know where is eveyone
		last_world_state = world_state.duplicate(true)
	
	for player in world_state.keys():
		world_state[player].erase("T")
		
		# if player connected recently and not in the last state
		if not last_world_state.has(player):
			# skip this player for now
			continue
		
		if world_state[player]["O"] == last_world_state[player]["O"]:
			# transforms are same
			if world_state[player]["C"] == last_world_state[player]["C"]:
				# rotations are same
				# last state and current are same,
				## this players camera didn't move
				# remove this player from state
				world_state.erase(player)
	
	if world_state.empty(): return
	
	world_state["T"] = OS.get_system_time_msecs()
	# Anti cheat
	# checks
	get_parent().send_world_state(world_state)
	last_world_state = world_state.duplicate(true)

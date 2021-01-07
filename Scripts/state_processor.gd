extends Node

var world_state = {}
var last_world_state = {}

var _frames := 0
func _physics_process(_delta):
	if get_parent().world_state_collection.empty(): return
	if not get_tree().has_network_peer(): return
	# if we are not the host, delete processor
	if not get_tree().is_network_server(): queue_free()
	
	
	_frames += 1
	if _frames%2 == 0:
		process_state()
		_frames = 0



func process_state():
	world_state = get_parent().world_state_collection.duplicate(true)
	# if its first time
	if last_world_state.empty():
		last_world_state = world_state.duplicate(true)
	
	# if someone joined and size changed
	elif last_world_state.size()<world_state.size():
		# update everyones state once
		## for adding new player to the list and
		### for new player to know where is eveyone
		for player in world_state:
			# find the new player
			if not last_world_state.has(player):
				last_world_state[player] = world_state[player].duplicate(true)
		#last_world_state = world_state.duplicate(true)
	
	for p_id in world_state.keys():
		
		# 0 is objects, we want players
		if p_id == 0:
			world_state[0].erase("T")
			if last_world_state.has(0):
				check_objs()
				if world_state[0].empty():
					world_state.erase(0)
			continue
		
		
		if not last_world_state.has(p_id):
			printerr("!!! player is not in last_world_state, wee should have added it in line 39 !!!")
		
		world_state[p_id].erase("T")
		
		
		
		check_key(p_id,"O")
		check_key(p_id,"C")
		if world_state[p_id].empty():
			world_state.erase(p_id)
	
	if world_state.empty(): return
	
	world_state["T"] = OS.get_system_time_msecs()
	# Anti cheat
	# checks
	get_parent().send_world_state(world_state)
#	last_world_state = world_state.duplicate(true)
	last_world_state = get_parent().world_state_collection.duplicate(true)


func check_key(p_id,key):
	if last_world_state[p_id].has(key):
		if world_state[p_id][key] == last_world_state[p_id][key]:
			world_state[p_id].erase(key)


func check_objs():
	for obj in world_state[0].keys():
		if last_world_state[0].has(obj):
			for k in world_state[0][obj].keys():
				if last_world_state[0][obj].has(k):
					if last_world_state[0][obj][k] == world_state[0][obj][k]:
						world_state[0][obj].erase(k)
		
		
		if world_state[0][obj].empty():
			world_state[0].erase(obj)








extends Spatial

var currently_moving := []
var last_world_state = 0
#TODO rewrite all of the code
export(float,0.05,1.0) var tween_duration = 0.1
# deck
var deck_path = preload("res://Scenes/deck.tscn")


#######################
# OVERRIDE FUNCTIONS 
#######################
func _ready():
	if not get_tree().has_network_peer():
		set_physics_process(false)
	
	for p in List.players:
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
	var tag=plo.get_node("CamController/Elevation/Camera/nametag/Viewport/tag")
	tag.text = List.players[id]
	get_node("OtherPlayers").add_child(plo)



# received world state from host
func process_received_world_state(world_state):
	# Buffer
	# Interpolate
	# Extrapolate
	if world_state["T"] < last_world_state: return
	
	last_world_state = world_state["T"]
	world_state.erase("T")
	
	# erase me, i dont want my own update
	world_state.erase(get_tree().get_network_unique_id())
	if $Player.is_dragging and $Player.dragging != null:
		if world_state.has(0):
			if world_state[0].has($Player.dragging.name):
				world_state[0].erase($Player.dragging.name)
	
	# if it was only me, return
	if world_state.empty(): return
	
	for player in world_state.keys():
		# 0 is objects
		if player == 0:
			process_objects(world_state[0])
			continue
		
		if get_node("OtherPlayers").has_node(str(player)):
			if world_state[player].has("O"):
				move_player(player,world_state[player]["O"],Vector3(0,0,0))
			if world_state[player].has("C"):
				move_player(player,Vector3(0,0,0),world_state[player]["C"])
			
		else:
			#MAYBE spawn player
			printerr("Player doesn't exist in scene")


func move_player(player,trans_origin = Vector3(0,0,0),CAM = Vector3(0,0,0)):
	var _cam_controller = get_node("OtherPlayers/"+str(player)+"/CamController")
	var _elevation = _cam_controller.get_node("Elevation")
	var _cam = _elevation.get_node("Camera")
	
	if trans_origin != Vector3(0,0,0):
		$Tween.interpolate_property(
				_cam_controller,
				"translation",
				_cam_controller.translation,
				trans_origin,
				tween_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
		)
		$Tween.start()
	 
	if CAM != Vector3(0,0,0):
		$Tween.interpolate_property(
				_elevation,
				"rotation_degrees",
				_elevation.rotation_degrees,
				Vector3(CAM.x,0,0),
				tween_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
			)
		$Tween.interpolate_property(
				_cam_controller,
				"rotation_degrees",
				_cam_controller.rotation_degrees,
				Vector3(0,CAM.y,0),
				tween_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
			)
		$Tween.interpolate_property(
				_cam,
				"translation",
				_cam.translation,
				Vector3(0,0,CAM.z),
				tween_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
			)
		$Tween.start()


func process_objects(opss):
	# opss = object_path_short's
	# ops = object_path_short
	for ops in opss:
		#FIXME make dices under Objects/dices/
		var _obj = get_node("Objects/cards/"+ops)
		if $Player.dragging == _obj:
			printerr("We should have deleted it on line 40-50")
			return
		
		if opss[ops].has("O"):
			$Tween.interpolate_property(
				_obj,
				"translation",
				_obj.transform.origin,
				opss[ops]["O"],
				tween_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
			)
			$Tween.start()
#			_obj.transform.origin = opss[ops]["O"]
		if opss[ops].has("R"):
			_obj.rotation_degrees = opss[ops]["R"]





func create_deck(holding,base):
	print("creating deck with ",holding," , ",base)
	if $Objects.has_node("d_"+base): return
	
	
	holding = $Objects/cards.get_node(holding)
	base = $Objects/cards.get_node(base)
	
	if holding.is_in_deck:
		#TODO remove from deck when moved out
		print("holding is already in deck")
		return
	
	var deck = deck_path.instance()
	deck.name = "d_"
	
	holding.is_in_deck = true
	holding.in_deck = deck
	base.is_in_deck = true
	base.in_deck = deck
	
	
	deck.deck.append(base)
	deck.deck.append(holding)
	
	$Objects.add_child(deck)
	
	deck.translation = base.translation + Vector3(0,0,0)
	deck.organize_cards()
	
	$CanvasLayer/Label2.text = "created deck,"+str(deck.deck)
	print("created deck")

func add_to_deck(holding,deck):
	print("adding ",holding," to deck ",deck)
	
	
	holding = $Objects/cards.get_node(holding)
	deck = $Objects.get_node(deck)
	
	if holding.is_in_deck:
		#TODO remove from deck when moved out
		print("holding is already in deck")
		return
	
	holding.is_in_deck = true
	holding.in_deck = deck
	
	
	
	deck.deck.append(holding)
	deck.organize_cards()
	
	$CanvasLayer/Label2.text = "added to deck,"+str(deck.deck)

extends Spatial

var currently_moving := []
var last_world_state = 0
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
			if world_state[0].has($Player._get_short_path($Player.dragging)):
				world_state[0].erase($Player._get_short_path($Player.dragging))
			# if we deleted our object and 0 is empty, delete 0
			if world_state[0].empty():
				world_state.erase(0)
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
		print("ops is === ",ops)
		var _obj = get_node("Objects"+ops)
		if _obj == null:
			printerr("_obj is null, in opss/ops")
			return
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


# fonc: 
# 0 = empty,
# 1 = create_deck,
# 2 = add_to_deck,
# 3 = remove_from_deck,
# 4 = remove_deck #MAYBE auto remove deck when its only one from deck
func deck_fonc(fonc,var1,var2):
	match fonc:
		0:
			printerr("deck_fonc: fonc is emtpy",fonc,var1,var2)
		1:
			print("df: creating deck ",var1,var2)
			create_deck(var1,var2)
		2:
			print("df: adding to deck",var1,var2)
			add_to_deck(var1,var2)
		3:
			print("df: removing from deck",var1,var2)
			remove_card_from_deck(var1)

func create_deck(holding,base):
	if base == null:
		printerr("T:base is null, cant create deck")
		return
	if holding == null:
		printerr("T:holding is null, cant create deck")
		return
	
	holding = get_node("Objects"+holding)
	base = get_node("Objects"+base)
	
	if holding.is_in_deck:
		print("T:holding is already in deck, cant create deck")
		return
	if base.is_in_deck:
		print("T:base is already in deck, cant create deck")
		return
	
	# MAYBE check if there is already a deck and create (1) of that
	
	print("creating deck with ",holding," , ",base)
	
	
	var deck = deck_path.instance()
	deck.name = base.name # MAYBE this fixes random names problem
	
	deck.transform.origin = base.transform.origin
	$Objects.add_child(deck)
	
	deck.add_card(base)
	deck.add_card(holding)
	
	
	$CanvasLayer/Label2.text = "created deck,"+str(deck.dek)

func add_to_deck(holding,deck):
	if deck == null:
		printerr("T:deck is null, cant add to deck")
		return
	if holding == null:
		printerr("T:holding is null, cant add to deck")
		return
	
	holding = get_node("Objects"+holding)
	deck = get_node("Objects"+deck)
	
	if deck == null:
		printerr("T:2deck is null, cant add to deck")
		return
	if holding == null:
		printerr("T:2holding is null, cant add to deck")
		return
	
	if holding.is_in_deck:
		print("T:holding is already in deck, cant add to deck")
		return
	
	
	deck.add_card(holding)
	
	
	$CanvasLayer/Label2.text = "added to deck,"+str(deck.dek)

func remove_card_from_deck(crd):
	if crd == null:
		printerr("T:crd is null, cant remove from deck")
		return
	
	crd = get_node("Objects"+crd)
	
	if crd == null:
		printerr("T:2crd is null, cant remove from deck")
		return
	
	if not crd.is_in_deck:
		if crd.in_deck == null:
			printerr("T:crd isnt even in deck, cant remove")
			return
		else:
			printerr("T:WTF IS HAPPENING")
	
	var deck = crd.in_deck
	
	deck.remove_card(crd)
	
	$CanvasLayer/Label2.text = "removed card from deck,crd="+str(crd)









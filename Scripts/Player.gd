extends Spatial
#######################
# EXPORT VARIABLES
#######################
export(int) var ray_length = 0
export(float,0,10) var drag_offset = 0.1
# default step for _rotating_degree
export(float,1,15) var rotating_degree_default := 5 # is angle
export(bool) var rotating_sptepped := true # is bool
export(float,1,90) var rotating_degree_stepped_default := 45 # is angle


#######################
# VARIABLES
#######################

# current_cast 
var current = null # is cast
# object we are currently holding
var dragging = null # is node
var is_dragging := false # is state
var _dragging_offset: Vector3
var _rotating_degree := 0 # is angle

onready var camera = $CamController/Elevation/Camera

var is_pp_on = false
var pp_off_env = preload("res://default_env.tres")
var pp_on_env = preload("res://Table_env.tres")


#######################
# OVERRIDE FUNCTIONS 
#######################
func _input(event):
	# cast_ray is in _input() instead of _process because:
	## we dont need to cast ray (for highlighting or moving)
	## if there is no input
	cast_ray(event)
	
	# temporary code for testing performace
	#######
	if Input.is_action_just_pressed("toggle_p_p"):
		if is_pp_on:
			camera.environment = pp_off_env
		else:
			camera.environment = pp_on_env
		is_pp_on = !is_pp_on
	if Input.is_action_just_pressed("move"):
		if not current.empty():
			roll_dice(current['collider'])
	#######

func _physics_process(_delta):
	
	if is_dragging:
		drag()
	if _rotating_degree != 0:
		rotate_obj()


#######################
# FUNCTIONS 
#######################
func cast_ray(event,_is_test:=false):
	# mouse position
	var mouse = get_viewport().get_mouse_position()
	# starting point of ray
	var from = camera.project_ray_origin(mouse)
	# ending point of ray
	var to = from + camera.project_ray_normal(mouse) * ray_length
	# casting ray
	var cast = camera.get_world().direct_space_state.intersect_ray(
		from,to,
		# if we are currently dragging an object,
		## we dont want our cast to hit it
		## we want our cast to hit things behind the object
		[dragging] if is_dragging else [],
		# in case the dragging objects collision mask is different
		dragging.get_collision_mask() if is_dragging else 2147483647,
		# we want cast to intersect with both rigidbody and area
		true,true
		)
	
	
	# cast is object we are hovering
	## or
	## cast is mouse intersecting with ground 
	## and cast is target position
	##
	## we need to asign it to current_cast to be able to move dragging object
	current = cast
	
	if _is_test:
		return current
	
	
	# called **once** everytime there is a moving input 
	## (not called when mouse is stationary)
	# we dont need to update highlight if we are not moving mouse
	if event is InputEventMouseMotion:
		highlight(current)
	
	#TODOF dont highlight object when dragging it
	##FIXED we are excluding dragging object from intersecting with cast
	
	# called **once** everytime there is an input (click or release)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# if pressing mouse left button
			if event.is_pressed():
				# start moving
				_drag_start(current)
			# if released button
			else:
				# we dont need to check current_cast because we will stop
				## dragging even if there is nothing in current_cast
				# stop moving
				_drag_stop()
	
	if event is InputEventKey:
		if event.is_action_pressed("rotate_obj"):
			_rotating_degree = rotating_degree_default
		elif event.is_action_released("rotate_obj"):
			_rotating_degree = 0
		elif event.is_action_pressed("_rotate_obj"):
			_rotating_degree = -rotating_degree_default
		elif event.is_action_released("_rotate_obj"):
			_rotating_degree = 0
		
		if event.is_action_pressed("flip"):
			flip_card()


# called from _physics_process every frame while is_dragging is true
func drag():
	# if cast is not intersencting with something
	# if current_cast is not pointing to an object
	# if there is nothing to drag then return
	if current.empty(): return
	# if dragging is not draggable      then return
	if not dragging.is_in_group("draggable"): return
	
	# debug
	get_node("../CanvasLayer/Label2").text = str(current)
	
	# if we are dragging a rigidbody we need to wake it
	## and clear its linear velocity because:
	### it builds up gravitational force when held in air
	### we want to clear that velocity
	if dragging is RigidBody:
		dragging.sleeping = false
		dragging.linear_velocity = Vector3.ZERO
	
	
	# target position of dragging object
	# current['position'] = position of mouse intersecting with something
	var trgt = (current['position'] + _dragging_offset)
	
	# translating object to desired location
	dragging.set_translation(trgt)
	
	
	# send loc
	define_obj_state(dragging)
#	#FIXMEremove lookat maybe
#	if true: return
#	# maybe no need to do this because table is flat
#	dragging.look_at(
#		(trgt+current['normal']*-1)*1,
#		#TODO check cards facing direction
#		Vector3.BACK*-1 # if card is facing_face == true?? else reversed
#		)
#



func highlight(_cast):
	# if cast isnt intersecting with anything, there is nothing to highlight
	if _cast.empty():return
	var obj = _cast['collider']
	
	if obj.is_in_group("highlight"):
		#TODO highlight
		get_node("../CanvasLayer/Label4").text = "*"+str(obj.name)+"*"
	else:
		#TODO clear highlight
		get_node("../CanvasLayer/Label4").text = str(obj.name)


# called from _physics_process every frame
## while rotating_degree != 0
func rotate_obj():
	# if cast is not intersencting with something
	if current.empty():return
	var obj = dragging if is_dragging else current['collider']
	# no need to make a new group called rotatable
	if not obj.is_in_group("draggable"): return
	
	if rotating_sptepped:
		var dir = _rotating_degree/abs(_rotating_degree)
		var amount = rotating_degree_stepped_default*dir
		
		for _obj in obj.get_children():
			# take _obj to closest step
			_obj.rotation_degrees.z = stepify(
				_obj.rotation_degrees.z,
				rotating_degree_stepped_default
				)
			# tick one step
			_obj.rotate_object_local(
				Vector3.UP,
				deg2rad(amount)
				)
		# resetting currently used degree because we want to rotate once
		_rotating_degree = 0
	else:
		for _obj in obj.get_children():
			_obj.rotate_object_local(
				Vector3.UP,
				deg2rad(_rotating_degree)
				)


func flip_card():
	# if cast is not intersencting with something
	if current.empty():return
	var obj = dragging if is_dragging else current['collider']
	if not obj.is_in_group("flippable"): return
	#MAYBE animate it
	for _obj in obj.get_children():
		_obj.rotate_object_local(
			Vector3.FORWARD,
			deg2rad(180)
			)


func _drag_start(_current):
	if _current.empty(): return
	
	dragging = _current['collider']
	if not dragging.is_in_group("draggable"): return
	
	
	var event = InputEventMouseMotion.new()
	var _second_ray = cast_ray(event,true)
	
	
	var off = dragging.get_node("CollisionShape").shape.extents.y
	var siz = dragging.get_node("CollisionShape").scale.y
	
	# if its deck bc deck/ is always at the bottom and mesh is moving,
	## if we make it higher, mesh also would go
	if dragging is deck:
		off = 0.05
		dragging.started_dragging()
	
	_dragging_offset = (     Vector3(0,off*siz,0)     )
	
	if dragging is card:
		if dragging.is_in_deck:
			# 3 = remove cardd
			net.deck_func(3,_get_short_path(dragging))
	
	#IMPORTANT this line is whole point of this func
	is_dragging = true
	
	# debug
	get_node("../CanvasLayer/Label3").text = \
			"dragging:"+str(dragging.name)
	get_node("../CanvasLayer/Label").text =\
			str(int(get_node("../CanvasLayer/Label").text)+1)


func _drag_stop():
	if current.empty(): return
	
	if dragging is deck:
		dragging.stopped_dragging()
	
	dragged_over(dragging,current['collider'])
	
	dragging = null
	#IMPORTANT this line is whole point of this func
	is_dragging = false
	
	# debug
	get_node("../CanvasLayer/Label3").text = "not dragging"
	get_node("../CanvasLayer/Label5").text =\
			str(int(get_node("../CanvasLayer/Label5").text)+1)


func dragged_over(dragged,over):
	if dragged == null: return
	if over == null: return
	
	# if dragged can interact with over
	if dragged is card and over is card:
		var d_sp = _get_short_path(dragged)
		var o_sp = _get_short_path(over)
		
		# if over is in a deck, add dragged to that deck
		if over.is_in_deck:
			var o_d_sp = _get_short_path(over.in_deck)
			# 2 = add
			net.deck_func(2,d_sp,o_d_sp)
		# else create new deck
		else:
			# 1 = create
			net.deck_func(1,d_sp,o_sp)
	elif dragged is card and over is deck:
		var d_sp = _get_short_path(dragged)
		var o_sp = _get_short_path(over)
		
		# 2 = create
		net.deck_func(2,d_sp,o_sp)


func _get_short_path(var obje)-> String:
	var pt = obje.get_path()
	var arry = str(pt).split("/",false)
	
	var is_passed_objs_node = false
	var nw_txt = ""
	
	for t in arry:
		if t == "Objects":
			is_passed_objs_node = true
		elif is_passed_objs_node:
			nw_txt += "/"+t
	
	# it is like /cards/areapoly3
	# it is like /areapoly2/areapoly3
	return nw_txt






# OLD CODE REPLACE IT
func roll_dice(var obj):
	if obj.is_in_group("dice"):
		obj.sleeping = false
		obj.apply_central_impulse(Vector3.UP*10)
		yield(get_tree().create_timer(0.2),"timeout")
		
		obj.apply_torque_impulse(Vector3.RIGHT*5)
		obj.apply_torque_impulse(Vector3.BACK*5)
		obj.apply_torque_impulse(Vector3.DOWN*5)
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var time = rng.randf_range(0.1,0.9)
		
		yield(get_tree().create_timer(time),"timeout")
		
		obj.apply_torque_impulse(Vector3.RIGHT*-4)
		obj.apply_torque_impulse(Vector3.BACK*-4)
		obj.apply_torque_impulse(Vector3.DOWN*-4)




func define_obj_state(obj):
	var obj_path_short = _get_short_path(obj)
	
	var state = {
		0:{
			"T":OS.get_system_time_msecs(),
			
			obj_path_short:{
				"O": obj.transform.origin,
				"R": obj.rotation_degrees
			}
			
		}
		
	}
	
	net.send_state(state)

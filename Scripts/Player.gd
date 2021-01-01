extends Spatial
#######################
# EXPORT VARIABLES
#######################
export(int) var ray_length = 0
export(float,0,10) var drag_offset = 0.1
# default step for _rotating_degree
export(float,1,15) var rotating_degree_default := 5 # is angle

#######################
# VARIABLES
#######################
# current_cast 
var current = null # is cast
# object we are currently holding
var dragging = null # is node
var is_dragging := false # is state
var _rotating_degree := 0 # is angle

onready var parent = get_parent()
onready var camera = $CamController/Elevation/Camera
onready var orr = $CamController/origin

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
	#######

var _frames := 0
func _physics_process(_delta):
	#TODO old code, change it 
	## bkz:Trello Fix camera
	if get_tree().has_network_peer():
		_frames += 1
		if _frames%3 == 0:
			parent.my_pos(
			camera.global_transform.origin,
			orr.global_transform.origin
			)
		_frames = 0
	
	if is_dragging:
		drag()
	if _rotating_degree != 0:
		rotate_obj()


#######################
# FUNCTIONS 
#######################
func cast_ray(event):
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
		elif event.is_action_pressed("_rotate_obj"):
			_rotating_degree = -rotating_degree_default
		elif event.is_action_released("rotate_obj"):
			_rotating_degree = 0
		elif event.is_action_released("_rotate_obj"):
			_rotating_degree = 0


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
	var trgt = (
		# position of mouse intersecting with something
		current['position']
		+ 
		# giving it an offset
		( current['normal'] * Vector3(0,drag_offset,0) )
	)
	# translating object to desired location
	dragging.set_translation(trgt)




func highlight(_cast):
	# if cast isnt intersecting with anything, there is nothing to highlight
	if _cast.empty():
		return
	
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
	
	obj.rotation_degrees += Vector3(0,_rotating_degree,0)


func _drag_start(_current):
	is_dragging = true
	dragging = _current['collider']
	# debug
	get_node("../CanvasLayer/Label3").text = \
			"dragging:"+str(_current['collider'].name)
	get_node("../CanvasLayer/Label").text =\
			str(int(get_node("../CanvasLayer/Label").text)+1)


func _drag_stop():
	is_dragging = false
	
	# debug
	get_node("../CanvasLayer/Label3").text = "not dragging"
	get_node("../CanvasLayer/Label5").text =\
			str(int(get_node("../CanvasLayer/Label5").text)+1)



# OLD CODE REPLACE IT
func roll_dice(var obj):
	if obj.is_in_group("dice"):
		obj.sleeping = false
		obj.apply_central_impulse(Vector3.UP*10)
		yield(get_tree().create_timer(0.2),"timeout")
		obj.apply_torque_impulse(Vector3.RIGHT*5)
		obj.apply_torque_impulse(Vector3.BACK*5)
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var time = rng.randf_range(0.1,0.9)
		
		yield(get_tree().create_timer(time),"timeout")
		
		obj.apply_torque_impulse(Vector3.RIGHT*-4)
		obj.apply_torque_impulse(Vector3.BACK*-4)




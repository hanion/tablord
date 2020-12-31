extends Spatial

export(int) var ray_length = 0
export(float,0,10) var drag_offset = 0.1

# current_cast 
var current = null # is cast
# object we are currently holding
var dragging = null # is node
var is_dragging := false # is state

onready var parent = get_parent()
onready var camera = $CamController/Elevation/Camera
onready var orr = $CamController/origin
#######################
# OVERRIDE FUNCTIONS 
#######################

func _input(event):
	cast_ray(event)


var frames := 0
func _physics_process(_delta):
	if get_tree().has_network_peer():
		frames += 1
		if frames%3 == 0:
			parent.my_pos(
			camera.global_transform.origin,
			orr.global_transform.origin
			)
		frames = 0
	
	if is_dragging:
		drag()


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
		# if we are currently dragging an object we dont want our cast to hit it
		# we want our cast to hit things behind the object
		[dragging] if is_dragging else [],
		# in case the dragging objects collision mask is different
		dragging.get_collision_mask() if is_dragging else 2147483647,
		# we want to intersect with rigidbody and area both
		true,true
		)
	
	# if cast intersected with something
	if not cast.empty():
		# cast is object we are hovering
		# or
		# cast is mouse intersecting with ground 
		# and cast is target position
		# 
		# we need to assign it to current_cast to be able to move dragging object
		current = cast
		
		# we dont need to update highlight if we are not moving mouse
		if event is InputEventMouseMotion:
			highlight(current)
		#TODO dont highlight object when dragging it
		
		# called **once** everytime there is an input (click or release)
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				# if pressing mouse left button
				if event.is_pressed():
					if current:
						
						get_node("../CanvasLayer/Label").text =\
							str(int(get_node("../CanvasLayer/Label").text)+1)
						
						#start moving
						_drag_start(current)
				# if released button and currently dragging an object
				elif current:
					get_node("../CanvasLayer/Label5").text =\
							str(int(get_node("../CanvasLayer/Label5").text)+1)
					
					#stop moving
					_drag_stop()





func drag():
	var obj = dragging
	get_node("../CanvasLayer/Label2").text = str(current)
	if obj is RigidBody:
		obj.sleeping = false
		obj.linear_velocity = Vector3.ZERO
	
	var trgt = (
		current['position']
		+
		( current['normal'] * Vector3(0,drag_offset,0) )
	)
	
	obj.set_translation(trgt)




func highlight(_cast):
	var obj = _cast['collider']
	if obj.is_in_group("highlight"):
		get_node("../CanvasLayer/Label4").text = "*"+str(obj.name)+"*"
	else:
		get_node("../CanvasLayer/Label4").text = str(obj.name)


func _drag_start(_current):
	is_dragging = true
	dragging = _current['collider']
	get_node("../CanvasLayer/Label3").text = "dragging:"+str(_current['collider'].name)


func _drag_stop():
	is_dragging = false
	get_node("../CanvasLayer/Label3").text = "not dragging"





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




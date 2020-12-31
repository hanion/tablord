extends Spatial

export (float) var ray_length = 100
export (float,0,1) var drag_offset

var draggables = []
var camera: Camera
var draging
var current = null
onready var table = get_node("../..")

#######################
# OVERRIDE FUNCTIONS 
#######################
func _ready():
	camera = get_tree().get_root().get_camera()
	set_physics_process(false)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			var a = clicked_at()
			get_node("../../CanvasLayer/Label3").text = str(a)
			if a:
				current = a
				get_node("../../CanvasLayer/Label3").text += str(a.name)
				#Start moving
				_drag_start(current)
		elif current:
			#stop moving
			_drag_stop()
	
	if event.is_action_pressed("move"):
		if event.is_pressed():
			var a = clicked_at()
			if a:
				current = a
				#Start moving
				get_parent().roll_dice(current)

func _physics_process(_delta):
	if not draging:
		return
	var mouse = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse)
	var to = from + camera.project_ray_normal(mouse) * ray_length
	
	var cast = camera.get_world().direct_space_state.intersect_ray(
		from,
		to,
		[draging],
		draging.get_collision_mask(),
		true,
		true
		)
		
	if not cast.empty():
		#move 
		moving(cast)


#######################
# FUNCTIONS 
#######################
#called once everytime user clicks
func clicked_at():
	var direct_state = get_world().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var collision = direct_state.intersect_ray(
		ray_from,
		ray_to,
		[],2147483647,
		true,
		true
		)
	
	if collision:
		get_node("../../CanvasLayer/Label").text = collision.collider.name
		get_node("../../CanvasLayer/Label").text += "\n"+str(collision)
		get_node("../../CanvasLayer/Label").text +="\nnormals:"+ \
		"\nx:"+str(abs(collision['normal'].x))+ \
		"\ny:"+str(abs(collision['normal'].y))+ \
		"\nz"+str(abs(collision['normal'].z))
		
		if collision.collider.is_in_group("draggable"):
			var obj = collision.collider
			return obj


var target_vector:Vector3
var motion:Vector3
var trgt:Vector3
#called every _physics_process tick if dragging
func moving(var cast):
	get_node("../../CanvasLayer/Label2").text = str(cast['collider'])+"\n"
	get_node("../../CanvasLayer/Label2").text += str(cast)
	get_node("../../CanvasLayer/Label2").text += "\n"+ str(cast['position'])
	get_node("../../CanvasLayer/Label2").text +="\n"+ str(cast['normal'].x)
	get_node("../../CanvasLayer/Label2").text +="\n"+ str(cast['normal'].y)
	get_node("../../CanvasLayer/Label2").text +="\n"+ str(cast['normal'].z)
	if current is RigidBody:
		current.sleeping = false
		current.linear_velocity = Vector3.UP
#	current.linear_velocity = Vector3.ZERO
	
	trgt = (
		cast['position']
		+
		( cast['normal'] * Vector3(0,drag_offset,0) )
	)
#	current.set_translation(trgt)
#	current.translation = trgt
	#TODO ??? dont tween, make it velocity so people can throw them
	$Tween.interpolate_property(
	current,
	"translation",
	current.translation,
	trgt,
	0.05,
	Tween.TRANS_SINE,
	Tween.EASE_OUT
	)
	$Tween.start()
	#TODO fix up direction
	var up = Vector3.FORWARD+10*cast['position']+0*(current.translation)
	current.look_at(current.translation+cast['normal']*-1,up)
##	current.linear_velocity = (trgt-current.translation)*3
#	table.obj_pos(current.name,current.translation)


#called once
func _drag_start(node):
	draging = node
	table._register_moving_obj(draging)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	set_physics_process(true)


#called once
func _drag_stop():
	$Tween.stop_all()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	set_physics_process(false)

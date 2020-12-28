extends Spatial

export (float) var ray_length = 100

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
			if a:
				current = a
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
		draging.get_collision_mask()
		)
		
	if not cast.empty():
		#move
		moving(cast)


#######################
# FUNCTIONS 
#######################
func clicked_at():
	var direct_state = get_world().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var collision = direct_state.intersect_ray(ray_from,ray_to)
	if collision:
		if collision.collider.is_in_group("draggable"):
			var obj = collision.collider
			return obj

var target_vector:Vector3
var motion:Vector3
var trgt:Vector3
func moving(var cast):
	current.sleeping = false
	current.linear_velocity = Vector3.ZERO
#	current.set_translation(cast['position']+Vector3(0,1,0))
	
	trgt = (cast['position']+Vector3(0,1,0))
	#TODO dont tween, make it velocity so people can throw them
	$Tween.interpolate_property(
	current,
	"translation",
	current.translation,
	trgt,
	0.5,
	Tween.TRANS_SINE,
	Tween.EASE_OUT
	)
	$Tween.start()
	current.linear_velocity = (trgt-current.translation)*3
#	table.obj_pos(current.name,current.translation)



func _drag_start(node):
	draging = node
	table._register_moving_obj(draging)
	set_physics_process(true)
func _drag_stop():
	$Tween.stop_all()
	set_physics_process(false)

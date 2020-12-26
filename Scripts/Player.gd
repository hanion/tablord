extends Spatial

onready var parent = get_parent()
onready var cam = $CamController/Elevation/Camera
onready var orr = $CamController/origin

var is_dragging := false
var prev_mouse_pos := Vector2.ZERO

func _ready():
#	if not PacketPeer.is_connected_to_host():
	if not get_tree().has_network_peer():
#	if not NetworkedMultiplayerENet.CONNECTION_CONNECTED:
		set_physics_process(false)

var frames := 0 #TODO open when using mp
func _physics_process(_delta):
	frames += 1
	if frames%3 == 0:
		parent.my_pos(
		get_tree().get_network_unique_id(),
		cam.global_transform.origin,
		orr.global_transform.origin
		)
		frames = 0

#func _input(event):
#	pass


#func clicked_at():
#	var direct_state = get_world().direct_space_state
#	var mouse_pos = get_viewport().get_mouse_position()
#	var ray_from = cam.project_ray_origin(mouse_pos)
#	var ray_to = ray_from + cam.project_ray_normal(mouse_pos) * 1000
#	var collision = direct_state.intersect_ray(ray_from,ray_to)
#	if collision:
#		if collision.collider.is_in_group("draggable"):
#			var obj = collision.collider
##			roll_dice(obj)#EXAMPLE
#			return obj
#


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




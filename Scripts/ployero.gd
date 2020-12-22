extends KinematicBody

var direction = Vector3()


func _physics_process(_delta):
	if is_network_master():
		direction = Vector3()
		
		if Input.is_action_pressed("ui_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("ui_right"):
			direction += transform.basis.x
		
		direction = direction.normalized()
		
		var _a = move_and_slide(direction*5,Vector3.UP)
		rpc_unreliable("set_pos",global_transform.origin)

remote func set_pos(var pos):
	global_transform.origin = pos

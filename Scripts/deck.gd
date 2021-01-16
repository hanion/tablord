extends Spatial
class_name deck

var deck : Array

var is_visual : bool = true
var is_hidden : bool = false
var is_infinite : bool = false
var can_be_owned : bool = true
var is_open : bool = false

var offset : float = 0.1

func organize_cards():
	for i in range(0,deck.size()):
		if deck[i] is RigidBody:
			deck[i].sleeping = true
		deck[i].translation = translation + Vector3(0,offset*i,0)
	
	adjust_mesh()

func adjust_mesh():
	# 0.1 - +0.1    off = +0.05
	$mesh.mesh.size = Vector3(1.2,0.2,1.4)
	$Area/shape.shape.extents = Vector3(0.6,0.1,0.7)
	$Area.translation.y = 0.1
	$mesh.translation.y = 0.1
	
	
	$Area/shape.shape.extents.y = offset*deck.size()/2 -(offset/2)
	$Area.translation.y = $Area/shape.shape.extents.y
	
#	for i in range(0,deck.size()):
#		$Area/shape.shape.extents.y += i*offset/2
#		$Area/shape.translation.y += i*offset/4
	
	$mesh.mesh.size.y = $Area/shape.shape.extents.y*2
	$mesh.translation.y = $Area.translation.y





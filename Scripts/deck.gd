extends Spatial
class_name deck

var dek : Array

var is_visual : bool = true
var is_hidden : bool = false
var is_infinite : bool = false
var can_be_owned : bool = true
var is_open : bool = false

var offset : float = 0.1

func add_card(card):
	dek.append(card)
	
	card.get_parent().remove_child(card)
	add_child(card)
	card.set_owner(self)
	
	card._assign_deck(self)
	
	organize_cards()


func remove_card(card):
	dek.erase(card)
	
	var cards = get_node("../cards")
	remove_child(card)
	cards.add_child(card)
	card.set_owner(cards)
	
	card._remove_deck()
	
	organize_cards()
	
	check_size()


func organize_cards():
	for i in range(0,dek.size()):
		if dek[i] is RigidBody:
			dek[i].sleeping = true
		
		dek[i].translation = Vector3(0,offset*i,0)
	
	_adjust_mesh()

func _adjust_mesh():
	var col = $CollisionShape
	# 0.1 - +0.1    off = +0.05
	$mesh.mesh.size = Vector3(1.2,0.2,1.6)
	col.shape.extents = Vector3(0.6,0.1,0.8)
	col.translation.y = 0.1
	$mesh.translation.y = 0.1
	
	
	col.shape.extents.y = offset*dek.size()/2 -(offset/2)
	col.translation.y = col.shape.extents.y
	
	$mesh.mesh.size.y = col.shape.extents.y*2
	$mesh.translation.y = col.translation.y
	
	started_dragging()
	stopped_dragging()


func started_dragging():
	for c in dek:
		c.collision_layer = 0
func stopped_dragging():
	if dek.size() == 0:
		# if its the last adjustment
		return
	var last_crd_i = dek.size()-1
	dek[last_crd_i].collision_layer = 1


func check_size():
	# only if we are not a hand
	if is_open:
		return
	
	# if only one card left, no need for us :(
	if dek.size() == 1:
		var last_card = dek[0]
		remove_card(last_card)
		dek = []
		
		last_card.transform.origin = transform.origin
		
		queue_free()


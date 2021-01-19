extends Spatial
class_name card

var value = 0
var is_in_deck : bool = false
var in_deck #deck node

# only call from deck
func _assign_deck(deck):
	is_in_deck = true
	in_deck = deck

# only call from deck
func _remove_deck():
	is_in_deck = false
	in_deck = null

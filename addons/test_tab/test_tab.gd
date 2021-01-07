tool
extends EditorPlugin


var _test_tab
var packed_scene = PackedScene.new()

func _enter_tree() -> void:
	_test_tab = preload("res://addons/test_tab/test_tab.tscn").instance()
	
	# warning-ignore:return_value_discarded
	add_control_to_bottom_panel(_test_tab, "Test")
#	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,_test_tab)
	
#	add_control_to_container(EditorPlugin.CONTAINER_PROPERTY_EDITOR_BOTTOM,_test_tab)
	
	
	# warning-ignore:return_value_discarded
	_test_tab.connect("visibility_changed", self,
			"_on_notes_tab_visibility_changed")
	_test_tab.get_node("exit").connect("pressed",self,"exit_but")
	
#	_test_tab.get_node("UI/WindowDialog").visible = true

func exit_but():
	_exit_tree()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(_test_tab)
	_test_tab.queue_free()

func _on_notes_tab_visibility_changed() -> void:
	if _test_tab.visible:
#		print("asdasdsd")
		_test_tab.grab_focus()

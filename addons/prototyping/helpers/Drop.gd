extends Panel
class_name PDrop

var container: VBoxContainer
var node: Node

func _init(node: Node):
	self.node = node
	
	var anchor = Utils.parent_that(node, is_visible_node)
	node.get_viewport().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(self, false, Node.INTERNAL_MODE_BACK)
	position = anchor.get_viewport_transform() * anchor.global_position
	
	container = VBoxContainer.new()
	
	var c = MarginContainer.new()
	c.add_theme_constant_override("margin_top", 6)
	c.add_theme_constant_override("margin_left", 6)
	c.add_theme_constant_override("margin_bottom", 6)
	c.add_theme_constant_override("margin_right", 6)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.add_child(c)
	c.add_child(container)
	add_child(scroll)
	
	build(node, false)
	
	# mouse_entered.connect(func (): build(node, true))
	# mouse_exited.connect(func (): build(node, false))


func _can_drop_data(at_position, data):
	return "type" in data and data["type"] == "P_CONNECT_SIGNAL"

func _drop_data(at_position, data):
	show_connect_popup(data)

func show_connect_popup(d):
	pass

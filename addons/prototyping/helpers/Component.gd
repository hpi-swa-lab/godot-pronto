extends Object
class_name PComponent

var popup
var component
var thumb

func _init(component: Node, image: Texture2D):
	self.component = component
	
	thumb = TextureRect.new()
	thumb.texture = image
	thumb.scale = Vector2(2, 2)
	component.get_parent().add_child.call_deferred(thumb, false, Node.INTERNAL_MODE_BACK)
	component.tree_exiting.connect(func ():
		thumb.queue_free())

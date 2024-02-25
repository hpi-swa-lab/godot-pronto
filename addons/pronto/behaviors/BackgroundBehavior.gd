@tool
#thumb("ProceduralSkyMaterial")
extends Behavior
class_name BackgroundBehavior
## The BackgroundBehavior is a [class Behavior] that adds a colored 
## rectangle with the size of the game's viewport 
## (see [method Utils.get_game_size]) to the scene.

## The color of the background rectangle
@export var color = Color.CORNFLOWER_BLUE:
	set(c):
		color = c
		_tex.color = c

var _tex: ColorRect

func _init():
	_tex = ColorRect.new()
	_tex.color = color

func _enter_tree():
	get_parent().add_child.call_deferred(_tex, false, Node.INTERNAL_MODE_FRONT)
	_tex.size = Utils.get_game_size()
	_tex.position = Vector2.ZERO

func _exit_tree():
	get_parent().remove_child.call_deferred(_tex)

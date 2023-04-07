@tool
extends Node
class_name PCollision

@export var limit_to_group: String = ""

signal collided(other: Area2D)

var thumb
var popup

func _ready():
	PComponent.new(self, preload("res://addons/prototyping/icons/Collision.svg"))
	
	(get_parent() as Area2D).area_entered.connect(func (other: Node):
		if limit_to_group == "" or other.is_in_group(limit_to_group):
			collided.emit(other))

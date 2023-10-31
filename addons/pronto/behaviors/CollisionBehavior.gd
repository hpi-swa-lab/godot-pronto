@tool
#thumb("GPUParticlesCollisionBox3D")
extends Behavior
class_name CollisionBehavior

## The CollisionBehavior is a [class Behavior] that emits [signal CollisionBehavior.collided]
## when its parent collides with another node.

## Set this to a group label in order to limit collisions to nodes in that group.
## Leave it at [code]""[/code] to collide with every node.
@export var limit_to_group: String = ""

## Gets emitted when the parent collides with another node.
##
## [param other] is the node that the parent collided with
##
## [param direction] is the normalized direction in which the [param other] 
## is from the parent node's position
signal collided(other: Node, direction: Vector2)

signal screen_exited()
signal screen_entered()
var screen_entered_emitted = false
var screen_exited_emitted = false

func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		var p = get_parent()
		if p is Area2D:
			(p as Area2D).area_entered.connect(on_collision)
			(p as Area2D).body_entered.connect(on_collision)
		if p is RigidBody2D:
			(p as RigidBody2D).body_entered.connect(on_collision)
			(p as RigidBody2D).contact_monitor = true
			(p as RigidBody2D).max_contacts_reported = max((p as RigidBody2D).max_contacts_reported, 1)
		if get_parent() is StaticBody2D:
			push_error("StaticBody2D cannot report collisions in Godot. Move the Collision to the other collision partner.")

func _physics_process(delta):
	if get_parent() is CharacterBody2D:
		var parent = (get_parent() as CharacterBody2D)
		for collision_index in parent.get_slide_collision_count():
			var collision = parent.get_slide_collision(collision_index)
			on_collision(collision.get_collider())

	if not Engine.is_editor_hint() and (get_parent() is RigidBody2D or get_parent() is CharacterBody2D or get_parent() is Area2D): 
		var current_camera = get_viewport().get_camera_2d()
		var x = 0 
		var y = 0
		if current_camera:
			x = get_viewport().get_camera_2d().global_position.x - (get_viewport_rect().size.x /2)
			y = get_viewport().get_camera_2d().global_position.y - (get_viewport_rect().size.y /2)
		if Rect2(Vector2(x,y) , get_viewport_rect().size).has_point(get_parent().position):
			if not screen_entered_emitted:
				screen_entered_emitted = true
				screen_entered.emit()
		else:
			if screen_entered_emitted and not screen_exited_emitted:
				screen_exited_emitted = true
				screen_exited.emit()


func on_collision(other: Node):
	if limit_to_group == "" or other.is_in_group(limit_to_group):
		collided.emit(other, Vector2(other.get_global_position() - get_parent().get_global_position()).normalized())

func is_valid_parent():
	var p = get_parent()
	return p is Area2D or p is RigidBody2D or p is CharacterBody2D

func lines():
	return super.lines() + ([Lines.DashedLine.new(self, get_parent(), func (f): return "", "collides")] if is_valid_parent() else [])

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()

func _get_configuration_warnings():
	if not is_valid_parent():
		return ["Collision only works with Area2D, RigidBody2D and CharacterBody2D"]
	return ""


func _on_area_2d_body_entered(body):
	var canvasModulate = get_parent().get_parent().get_parent().find_child("CanvasModulate")
	canvasModulate.hide()
	var flashLight = get_parent().find_child("Flashlight")
	flashLight.hide()
	var timer = get_parent().get_parent().get_parent().find_child("Timer")
	timer.start(4)

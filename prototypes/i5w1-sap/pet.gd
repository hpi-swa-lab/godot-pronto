extends RigidBody2D


var _queued_position 


func queue_position(pos: Vector2):
	_queued_position = pos


func _integrate_forces(state: PhysicsDirectBodyState2D):
	if _queued_position != null:
		state.transform.origin = _queued_position
		_queued_position = null

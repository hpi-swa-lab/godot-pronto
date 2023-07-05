extends RigidBody2D

@export var petname := ""

var default_health:
	get:
		return G.at("%s_health" % petname)

var attacks:
	get:
		return G.at("%s_attacks" % petname)

var _queued_position 

func queue_position(pos: Vector2):
	_queued_position = pos

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if _queued_position != null:
		state.transform.origin = _queued_position
		_queued_position = null

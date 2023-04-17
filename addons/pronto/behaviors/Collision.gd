@tool
#thumb("GPUParticlesCollisionBox3D")
extends Behavior

@export var limit_to_group: String = ""

signal collided(other: Area2D)

func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		(get_parent() as Area2D).area_entered.connect(on_collision)
		(get_parent() as Area2D).body_entered.connect(on_collision)

func on_collision(other: Node):
	if limit_to_group == "" or other.is_in_group(limit_to_group):
		collided.emit(other)

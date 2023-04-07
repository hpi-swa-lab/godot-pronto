@tool
extends TextureRect

@export var limit_to_group: String = ""

signal collided(other: Area2D)

func _ready():
	texture = Utils.icon_from_theme("GPUParticlesCollisionBox3D", self)
	
	if not Engine.is_editor_hint():
		(get_parent() as Area2D).area_entered.connect(func (other: Node):
			if limit_to_group == "" or other.is_in_group(limit_to_group):
				collided.emit(other))

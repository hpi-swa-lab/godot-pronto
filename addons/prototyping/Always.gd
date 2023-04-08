@tool
extends TextureRect

signal always(delta)

@export var paused = false

func _ready():
	texture = Utils.icon_from_theme("Loop", self)

func _process(delta):
	if not Engine.is_editor_hint() and not paused:
		always.emit(delta)

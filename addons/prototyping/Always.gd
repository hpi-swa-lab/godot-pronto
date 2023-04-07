@tool
extends TextureRect

signal always(delta)

func _ready():
	texture = Utils.icon_from_theme("Loop", self)

func _process(delta):
	always.emit(delta)
